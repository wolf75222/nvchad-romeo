# Troubleshooting

[README](../README.md) · [Usage](usage.md) · [Customize](customize.md) · [How it works](how-it-works.md) · **Troubleshooting** · [Development](development.md)

| Symptom | Fix |
|---|---|
| `nvim: command not found` after the install | open a new shell (or `hash -r`); `~/.local/bin` must be in `PATH` |
| the old `nvim` starts | `which nvim`: a `module load` or another `PATH` entry comes before `~/.local/bin` |
| squares or `?` instead of icons | set a [Nerd Font](https://www.nerdfonts.com/) in the terminal of your computer (e.g. `brew install --cask font-jetbrains-mono-nerd-font`) |
| wrong colors | the terminal must support 24-bit color; in tmux: `set -g default-terminal "tmux-256color"` and `set -as terminal-features ",*:RGB"` |
| a yank does not reach the clipboard of your computer | the terminal must accept OSC 52 (iTerm2: *Applications in terminal may access clipboard*; tmux: `set -g set-clipboard on`) |
| clangd does not find the headers | give it a `compile_commands.json` ([Usage](usage.md#code)) |
| a server is missing | `:Mason`, `:MasonInstallAll`, `:LspInfo`, and `~/.local/state/nvim/mason.log` |
| no highlighting for a language | `:TSInstall <language>`; `:checkhealth nvim-treesitter` |
| `nvim` complains that Neovim is not installed for aarch64 | run `~/nvchad-romeo/install.sh` on that node once ([Usage](usage.md#grace-hopper-nodes)) |
| something else | `nvim +checkhealth`, then `~/nvchad-romeo/tests/check.sh` |

To start over: `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/.local/share/nvchad-romeo && ~/nvchad-romeo/install.sh`.

To uninstall: the same `rm -rf`, then `rm ~/.local/bin/nvim ~/.config/nvim` (and move back your `~/.config/nvim.before-nvchad-romeo.*`).
