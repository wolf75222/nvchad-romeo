# How it works

[README](../README.md) · [Usage](usage.md) · [Customize](customize.md) · **How it works** · [Troubleshooting](troubleshooting.md) · [Development](development.md)

`install.sh` runs on ROMEO, in your home, without root, and can run again at any time:

1. **Binaries** for the architecture of the node (`uname -m`) in `~/.local/share/nvchad-romeo/<arch>/`: Neovim (pinned, `NVIM_VERSION`), ripgrep (for Telescope) and Node.js LTS (for the servers Mason installs with npm: pyright, bashls, jsonls, yamlls, prettier). ROMEO has none of them.
2. **Command**: `~/.local/bin/nvim` → `bin/nvim`, a wrapper that puts these binaries in `PATH` and starts the Neovim of the node's architecture. `~/.local/bin` is in the default `PATH` of ROMEO.
3. **Config**: `~/.config/nvim` → `nvim/` of the repository. An existing config is kept as `~/.config/nvim.before-nvchad-romeo.<date>`.
4. **Plugins**: `nvim --headless "+Lazy! restore"` installs them at the versions of `lazy-lock.json`, then base46 compiles the theme.
5. **Treesitter parsers and Mason tools**: `share/install-tools.lua` in a headless nvim compiles the parsers of `lua/plugins/init.lua` and installs the servers and formatters of `lua/configs/` (what `:MasonInstallAll` does), and waits until all are done.

**tree-sitter**: nvim-treesitter compiles the parsers with the tree-sitter CLI, whose binaries need glibc 2.39; ROMEO (RHEL 9) has 2.34. `share/tree-sitter` stands in for it: nvim-treesitter only calls `tree-sitter build -o parser.so` in the parser's directory, which is `cc -O2 -fPIC -shared -Isrc src/parser.c src/scanner.c`.

**Two architectures, one home**: the parsers (`~/.local/share/nvim/site-<arch>`) and the Mason tools (`~/.local/share/nvim/mason-<arch>`) are binaries, kept apart per architecture; the plugins and the config are shared.

**Clipboard**: over ssh (`$SSH_TTY`), the `+` and `*` registers are copied with OSC 52, the escape sequence that asks the terminal to put text in the clipboard of your computer. Pasting reads the unnamed register: reading the clipboard through the terminal is blocked or slow in most terminals.

**Space**: about 750 MB per architecture (Neovim 40 MB, Node.js 200 MB, Mason tools 450 MB, plugins 55 MB, parsers 25 MB).
