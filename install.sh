#!/usr/bin/env bash
# Installs NvChad on ROMEO, in your home, without root: Neovim, ripgrep and Node.js for this node's architecture,
# the config of this repository as ~/.config/nvim, then the plugins, the Treesitter parsers and the Mason tools.
#
#   ./install.sh                 run it on ROMEO (a login node: x86_64, or a Grace Hopper node: aarch64)
#   ./install.sh --no-tools      only Neovim, the config and the plugins (no Treesitter parsers, no Mason tools)
#   ./install.sh --force         downloads Neovim, ripgrep and Node.js again
#
# Run it again after `git pull`: it keeps what is already there and puts the plugins at the versions of lazy-lock.json.
set -euo pipefail

ROOT=$(cd "$(dirname "$0")" && pwd)
NVIM_VERSION=${NVIM_VERSION:-v0.12.3}
RG_VERSION=${RG_VERSION:-14.1.1}
NODE_MAJOR=${NODE_MAJOR:-22}
ARCH=$(uname -m)
PREFIX=${NVCHAD_ROMEO_PREFIX:-${XDG_DATA_HOME:-$HOME/.local/share}/nvchad-romeo}/$ARCH
CONFIG=${XDG_CONFIG_HOME:-$HOME/.config}/nvim
BIN_DIR=$HOME/.local/bin
TOOLS=1 FORCE=0

while [ $# -gt 0 ]; do
  case $1 in
    --no-tools) TOOLS=0; shift ;;
    --force) FORCE=1; shift ;;
    -h|--help) sed -n '2,9p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    *) echo "unknown option $1 (see --help)" >&2; exit 2 ;;
  esac
done

if [ -t 1 ]; then B=$'\e[1m' G=$'\e[32m' R=$'\e[31m' N=$'\e[0m'; else B='' G='' R='' N=''; fi
step() { printf '%s\n' "${B}==>${N} $*"; }
ok() { printf '%s\n' "    ${G}ok${N} $*"; }
die() { printf '%s\n' "${R}error:${N} $*" >&2; exit 1; }

case $ARCH in
  x86_64) nvim_arch=x86_64 rg_target=x86_64-unknown-linux-musl node_arch=x64 ;;
  aarch64) nvim_arch=arm64 rg_target=aarch64-unknown-linux-gnu node_arch=arm64 ;;
  *) die "unsupported architecture $ARCH" ;;
esac
[ "$(uname -s)" = Linux ] || die "run install.sh on ROMEO (Linux), e.g. ssh romeo '~/nvchad-romeo/install.sh'"

# ---------------------------------------------------------------- tools of the system

step "System tools"
for tool in git curl tar gzip unzip cc make; do command -v $tool >/dev/null || die "$tool is missing"; done
ok "git, curl, tar, unzip, cc, make"

# ---------------------------------------------------------------- Neovim, ripgrep, Node.js

fetch() {  # fetch URL DIR: extracts the tarball at URL into DIR (replaced)
  local tmp
  tmp=$(mktemp -d "$PREFIX/.download.XXXXXX")
  curl -fsSL --retry 3 "$1" | tar -xz -C "$tmp" --strip-components=1 || { rm -rf "$tmp"; die "cannot download $1"; }
  rm -rf "$2" && mv "$tmp" "$2"
}

step "Neovim, ripgrep, Node.js for $ARCH: $PREFIX"
mkdir -p "$PREFIX/bin"
if [ "$FORCE" = 1 ] || [ "$("$PREFIX/nvim/bin/nvim" --version 2>/dev/null | head -1)" != "NVIM $NVIM_VERSION" ]; then
  fetch "https://github.com/neovim/neovim/releases/download/$NVIM_VERSION/nvim-linux-$nvim_arch.tar.gz" "$PREFIX/nvim"
fi
ok "$("$PREFIX/nvim/bin/nvim" --version | head -1)"

if [ "$FORCE" = 1 ] || [ ! -x "$PREFIX/ripgrep/rg" ]; then
  fetch "https://github.com/BurntSushi/ripgrep/releases/download/$RG_VERSION/ripgrep-$RG_VERSION-$rg_target.tar.gz" "$PREFIX/ripgrep"
fi
ln -sf "$PREFIX/ripgrep/rg" "$PREFIX/bin/rg"
ok "$("$PREFIX/bin/rg" --version | head -1)"

# Node.js: for the LSP servers and formatters Mason installs with npm (pyright, bash, json, yaml, prettier)
if [ "$FORCE" = 1 ] || [ "$("$PREFIX/node/bin/node" -p 'process.versions.node.split(".")[0]' 2>/dev/null)" != "$NODE_MAJOR" ]; then
  base=https://nodejs.org/dist/latest-v$NODE_MAJOR.x
  file=$(curl -fsSL "$base/SHASUMS256.txt" | grep -o "node-v[0-9.]*-linux-$node_arch.tar.gz" | head -1) \
    || die "cannot find Node.js $NODE_MAJOR for linux-$node_arch at $base"
  fetch "$base/$file" "$PREFIX/node"
fi
for exe in node npm npx; do ln -sf "$PREFIX/node/bin/$exe" "$PREFIX/bin/$exe"; done
ok "Node.js $("$PREFIX/bin/node" --version)"

# tree-sitter: the official CLI needs a newer glibc than ROMEO's, share/tree-sitter compiles the parsers with cc
ln -sf "$ROOT/share/tree-sitter" "$PREFIX/bin/tree-sitter"
ok "tree-sitter stand-in (cc)"

# ---------------------------------------------------------------- command and config

step "Command: $BIN_DIR/nvim"
mkdir -p "$BIN_DIR"
if [ -e "$BIN_DIR/nvim" ] && [ "$(readlink "$BIN_DIR/nvim")" != "$ROOT/bin/nvim" ]; then
  mv "$BIN_DIR/nvim" "$BIN_DIR/nvim.before-nvchad-romeo"
  printf '%s\n' "    your previous nvim was kept as $BIN_DIR/nvim.before-nvchad-romeo"
fi
ln -sfn "$ROOT/bin/nvim" "$BIN_DIR/nvim"
ok "$BIN_DIR/nvim -> $ROOT/bin/nvim"
case ":$PATH:" in *":$BIN_DIR:"*) ;; *)
  printf '%s\n' "    ${R}add $BIN_DIR to your PATH${N}: echo 'export PATH=\"$BIN_DIR:\$PATH\"' >> ~/.bashrc" ;; esac

step "Config: $CONFIG"
mkdir -p "$(dirname "$CONFIG")"
if [ -e "$CONFIG" ] && [ "$(readlink "$CONFIG")" != "$ROOT/nvim" ]; then
  backup=$CONFIG.before-nvchad-romeo.$(date +%Y%m%d-%H%M%S)
  mv "$CONFIG" "$backup"
  printf '%s\n' "    your previous config was kept as $backup"
fi
ln -sfn "$ROOT/nvim" "$CONFIG"
ok "$CONFIG -> $ROOT/nvim"

# ---------------------------------------------------------------- plugins, parsers, Mason tools

nvim() { "$ROOT/bin/nvim" --headless "$@"; }

step "Plugins (lazy-lock.json)"
nvim "+Lazy! restore" +qa >/dev/null 2>&1 || die "lazy.nvim could not install the plugins: run nvim and look at :Lazy"
nvim "+lua require('base46').load_all_highlights()" +qa
ok "$(find "${XDG_DATA_HOME:-$HOME/.local/share}/nvim/lazy" -mindepth 1 -maxdepth 1 -type d | wc -l | tr -d ' ') plugins"

if [ "$TOOLS" = 1 ]; then
  step "Treesitter parsers (compiled with cc) and Mason tools (LSP servers, formatters)"
  # nvim-treesitter writes its progress on stderr: kept in a log
  nvim "+luafile $ROOT/share/install-tools.lua" 2>"$PREFIX/install-tools.log"
  printf '%s\n' "    log: $PREFIX/install-tools.log"
fi

cat <<EOF

${G}NvChad is installed.${N} Open a new shell on ROMEO (or: hash -r), then:

    nvim file.cpp        # <space>ff files, <space>fg grep, <space>e tree, <space>ch all the keys
    nvim +checkhealth    # if something does not work

Update: cd $ROOT && git pull && ./install.sh
EOF
