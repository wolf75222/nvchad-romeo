# nvchad-romeo

[NvChad](https://nvchad.com/) on the [ROMEO](https://romeo.univ-reims.fr/) cluster: one command installs Neovim, NvChad, the Treesitter parsers and the LSP servers in your home, without root, then `nvim` works as on your computer. C++, CUDA, Python, Lua, shell, CMake, JSON, YAML: completion, diagnostics, go to definition, formatting on save.

![The install command run on a computer, then nvim over ssh on ROMEO: the NvChad dashboard, a file found with Telescope, the error clangd reports and its fix, completion, clang-format on save, the file tree](img/nvchad-romeo.gif)

## Install

On your computer, once `ssh romeo` logs you into ROMEO:

```bash
ssh romeo 'git clone https://github.com/wolf75222/nvchad-romeo.git ~/nvchad-romeo && ~/nvchad-romeo/install.sh'
```

Or the same command without `ssh romeo '...'` in a shell on ROMEO. It takes about 30 seconds. To update: `cd ~/nvchad-romeo && git pull && ./install.sh`.

## Use

| On ROMEO | |
|---|---|
| `nvim file.cpp` | NvChad, theme `github_dark` with a transparent background |
| `<space>ff` / `<space>fg` / `<space>fr` | find files, grep, recent files |
| `<space>e` / `<C-n>` | file tree |
| `gd` / `K` / `<space>ra` | go to definition, documentation, rename |
| `<space>cf` | format (also on save: clang-format, ruff, stylua, shfmt, prettier) |
| `<space>th` | pick another theme |
| `<space>ch` | all the keys |

A yank goes to the clipboard of your computer, through the terminal (OSC 52).

## Docs

[Usage](docs/usage.md) · [Customize](docs/customize.md) · [How it works](docs/how-it-works.md) · [Troubleshooting](docs/troubleshooting.md) · [Development](docs/development.md)
