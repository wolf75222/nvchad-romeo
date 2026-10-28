#!/usr/bin/env python3
"""Records the README's GIF from a real run on ROMEO: the install command typed in a terminal of your computer, then
`nvim` over ssh on a small C++ file: find a file, the error clangd reports, fixed, completion, formatting on save,
the file tree.

    python tests/demo.py record      # real run: removes nvchad-romeo from your ROMEO account first, then installs it
    python tests/demo.py render      # img/nvchad-romeo.gif from tests/demo-frames/

Needs pyte and Pillow (pip install pyte pillow), `ssh romeo` without a password, and a Nerd Font for the icons
(JetBrainsMono Nerd Font: brew install --cask font-jetbrains-mono-nerd-font).
"""

import argparse
import hashlib
import json
import os
import shutil
import subprocess
import sys
import tempfile
import time

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
from tui import BACKGROUND, Term, render_png  # noqa: E402

REPO = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
FRAMES = os.path.join(REPO, "tests", "demo-frames")
WIDTH, HEIGHT = 1280, 760                   # frames; terminal of 12 x 25 px cells
COLS, ROWS = 106, 30
HOST = os.environ.get("NVCHAD_ROMEO_HOST", "romeo")
INSTALL = "ssh romeo 'git clone https://github.com/wolf75222/nvchad-romeo.git ~/nvchad-romeo && ~/nvchad-romeo/install.sh'"
OPEN = "ssh -t romeo 'cd heat && nvim'"

HEAT = r"""#include <cstdio>
#include <vector>

// One step of the 1D heat equation, explicit Euler
void step(std::vector<double>& u, double r) {
  std::vector<double> next(u.size());
  for (std::size_t i = 1; i + 1 < u.size(); ++i)
    next[i] = u[i] + r * (u[i - 1] - 2 * u[i] + u[i + 1]);
  u.swap(nxt);
}

int main() {
  std::vector<double> u(64, 0.0);
  u[32] = 1.0;
  for(int t=0;t<100;++t) step(u,0.25);
  std::printf("u[32] = %f\n", u[32]);
}
"""
CMAKE = "cmake_minimum_required(VERSION 3.20)\nproject(heat CXX)\nadd_executable(heat heat.cpp)\n"


class Recorder:
    """Frames as PNG files plus an index: [file, milliseconds shown, kind]."""

    def __init__(self):
        shutil.rmtree(FRAMES, ignore_errors=True)
        os.makedirs(FRAMES)
        self.index = []
        self.last = None

    def add(self, image, ms, kind="normal"):
        digest = hashlib.md5(image.tobytes()).hexdigest()
        if digest == self.last and self.index:     # same picture: show the previous frame longer
            self.index[-1][1] += ms
            self.save()
            return
        self.last = digest
        name = "%04d.png" % len(self.index)
        image.save(os.path.join(FRAMES, name))
        self.index.append([name, ms, kind])
        self.save()

    def save(self):
        with open(os.path.join(FRAMES, "index.json"), "w") as f:
            json.dump(self.index, f)


def terminal_image(term):
    from PIL import Image
    img = render_png(term.snapshot(), cell_w=12, cell_h=25, font_size=20)
    canvas = Image.new("RGB", (WIDTH, HEIGHT), BACKGROUND)
    canvas.paste(img, ((WIDTH - img.width) // 2, (HEIGHT - img.height) // 2))
    return canvas


def remote(script):
    subprocess.run(["ssh", "-o", "BatchMode=yes", HOST, script], check=True, stderr=subprocess.DEVNULL)


def prepare(fresh):
    """The C++ project nvim opens (the demo edits it), and a fresh ROMEO account for the install."""
    if fresh:
        remote("rm -rf ~/nvchad-romeo ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/.local/share/nvchad-romeo "
               "~/.config/nvim ~/.local/bin/nvim")
    else:  # the theme picker of the demo leaves the colors of the last theme it showed in the base46 cache
        remote("~/.local/bin/nvim --headless \"+lua require('base46').load_all_highlights()\" +qa")
    remote("rm -rf ~/heat && mkdir -p ~/heat")
    subprocess.run(["ssh", "-o", "BatchMode=yes", HOST, "cat > ~/heat/heat.cpp"], input=HEAT.encode(), check=True,
                   stderr=subprocess.DEVNULL)
    subprocess.run(["ssh", "-o", "BatchMode=yes", HOST, "cat > ~/heat/CMakeLists.txt"], input=CMAKE.encode(),
                   check=True, stderr=subprocess.DEVNULL)


def record(args):
    rec = Recorder()
    prepare(not args.no_install)
    # a stand-in ssh first in PATH: the real one, without the warnings of OpenSSH about post-quantum key exchange
    stub = tempfile.mkdtemp(prefix="nvchad-demo-ssh.")
    with open(os.path.join(stub, "ssh"), "w") as f:
        f.write('#!/bin/sh\nexec %s -o LogLevel=ERROR "$@"\n' % shutil.which("ssh"))
    os.chmod(os.path.join(stub, "ssh"), 0o755)
    env = {"PS1": "\\[\\e[1;32m\\]~\\[\\e[0m\\] $ ", "HISTFILE": "/dev/null", "BASH_SILENCE_DEPRECATION_WARNING": "1",
           "PATH": stub + ":" + os.environ["PATH"]}
    t = Term(["bash", "--noprofile", "--norc", "-i"], cols=COLS, rows=ROWS, env=env)
    start = time.time()

    def shot(ms, kind="normal"):
        rec.add(terminal_image(t), ms, kind)

    def type_(text, every=2):
        for i, ch in enumerate(text):
            t.send(ch)
            t.sleep(0.03)
            if i % every == every - 1:
                shot(60)

    def keys(text, wait, ms):
        t.send(text)
        t.sleep(wait)
        shot(ms)

    t.sleep(1.0)
    shot(900)
    if not args.no_install:
        type_(INSTALL, every=3)
        shot(700)
        t.send("enter")
        deadline = time.time() + 600
        while time.time() < deadline and "NvChad is installed" not in t.text():
            t.sleep(1.0)
            shot(400, "install")
        if "NvChad is installed" not in t.text():
            t.close()
            sys.exit("the install did not finish in 10 min:\n" + t.text())
        t.sleep(0.5)
        shot(3500)
        t.send("clear\r")
        t.sleep(0.5)
        shot(300)

    type_(OPEN)
    shot(600)
    t.send("enter")
    t.wait_for("Find File", timeout=30)                   # the NvChad dashboard
    t.sleep(1.5)
    shot(2200)

    keys(" ff", 1.5, 900)                                  # Telescope: find files
    type_("hea", every=1)
    t.sleep(0.8)
    shot(900)
    t.send("enter")
    t.sleep(1.0)
    shot(800)
    t.wait_for("nxt", timeout=10)
    t.sleep(6.0)                                           # clangd indexes and reports the error
    shot(1800)

    keys("]d", 1.0, 900)                                   # next diagnostic
    keys("\x17d", 1.2, 3000)                               # <C-w>d: the message of the diagnostic
    t.send("esc")
    t.sleep(0.4)
    t.send("c")
    t.send("i")
    t.send("w")
    t.sleep(0.4)
    type_("next", every=1)
    t.send("esc")
    t.sleep(3.0)                                           # clangd: the error is gone
    shot(2000)

    keys("16G", 0.5, 500)                                  # completion: a line after the printf
    t.send("o")
    t.sleep(0.3)
    type_('std::printf("%zu\\n", u.si', every=2)
    t.sleep(1.5)
    shot(2600)                                             # clangd proposes size()
    keys("\r", 0.8, 800)
    type_(");", every=1)
    t.send("esc")
    t.sleep(0.5)
    keys("15G", 0.6, 1600)                                 # the line that is not formatted
    type_(":w", every=1)
    keys("\r", 2.5, 3000)                                  # formatted on save by clang-format

    keys(" e", 1.5, 2600)                                  # file tree
    keys(" e", 0.8, 600)

    type_(":qa", every=1)
    keys("\r", 2.0, 2500)
    t.close()
    print("%d frames in %s, %.0f s" % (len(rec.index), FRAMES, time.time() - start))


def render(args):
    from PIL import Image
    with open(os.path.join(FRAMES, "index.json")) as f:
        index = json.load(f)
    install = [i for i, (_, _, kind) in enumerate(index) if kind == "install"]
    if len(install) > 10:                                 # the install runs for about 30 s: 10 frames of it
        keep = {install[round(k * (len(install) - 1) / 9)] for k in range(10)}
        index = [entry for i, entry in enumerate(index) if i not in install or i in keep]
    for i, entry in enumerate(index[:-1]):               # the install waits for downloads: shorter, but not its end
        if entry[2] == "install" and index[i + 1][2] == "install":
            entry[1] = min(entry[1], 700)
    scale = args.width / WIDTH
    images, durations = [], []
    for name, ms, _ in index:
        img = Image.open(os.path.join(FRAMES, name)).convert("RGB")
        if scale != 1:
            img = img.resize((args.width, round(HEIGHT * scale)), Image.LANCZOS)
        images.append(img.quantize(colors=128, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE))
        durations.append(ms)
    os.makedirs(os.path.dirname(args.out), exist_ok=True)
    images[0].save(args.out, save_all=True, append_images=images[1:], duration=durations, loop=0, optimize=True)
    print("%s: %d frames, %.0f s, %d KB" % (args.out, len(images), sum(durations) / 1000, os.path.getsize(args.out) // 1024))


def main():
    p = argparse.ArgumentParser()
    sub = p.add_subparsers(dest="cmd", required=True)
    r = sub.add_parser("record")
    r.add_argument("--no-install", action="store_true", help="only the nvim part, on an installed account")
    d = sub.add_parser("render")
    d.add_argument("--out", default=os.path.join(REPO, "img", "nvchad-romeo.gif"))
    d.add_argument("--width", type=int, default=960)
    args = p.parse_args()
    return record(args) if args.cmd == "record" else render(args)


if __name__ == "__main__":
    main()
