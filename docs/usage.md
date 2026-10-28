# Usage

[README](../README.md) · **Usage** · [Customize](customize.md) · [How it works](how-it-works.md) · [Troubleshooting](troubleshooting.md) · [Development](development.md)

`<leader>` is space. `<space>ch` (or `:NvCheatsheet`) lists all the keys, `<space>wK` too with which-key.

## Files

| Key | |
|---|---|
| `<space>ff` | find files (ripgrep) |
| `<space>fa` | find all files, hidden and ignored ones too |
| `<space>fg` / `<space>fw` | grep in the project |
| `<space>fr` / `<space>fo` | recent files |
| `<space>fb` | open buffers |
| `<space>fz` | search in the current file |
| `<space>e` / `<C-n>` | file tree (dotfiles and `.gitignore`d files shown): `a` new file, `r` rename, `d` delete |
| `<tab>` / `<S-tab>` / `<space>x` | next buffer, previous buffer, close buffer |
| `<C-s>` | save |

## Code

| Key | |
|---|---|
| `gd` / `gD` / `<space>D` | definition, declaration, type definition |
| `K` | documentation under the cursor |
| `<space>ra` | rename the symbol |
| `<space>ca` | code actions (clangd fix-its, ruff fixes...) |
| `<space>xx` | diagnostics of the project |
| `[d` / `]d` | previous / next diagnostic |
| `<space>cf` / `<space>fm` | format; files are also formatted on save |
| `<space>/` | comment the line or the selection |

For clangd to know your include paths and flags, give it a `compile_commands.json` at the root of the project: `cmake -B build -DCMAKE_EXPORT_COMPILE_COMMANDS=ON && ln -s build/compile_commands.json .`.

## Terminal and windows

| Key | |
|---|---|
| `<A-i>` | floating terminal (`<C-x>` leaves terminal mode) |
| `<A-h>` / `<A-v>` | horizontal / vertical terminal |
| `<C-h>` `<C-j>` `<C-k>` `<C-l>` | move between windows |

`<A-...>` needs the Option key to send Meta in your terminal (Terminal.app: *Use Option as Meta key*; iTerm2: *Left Option key: Esc+*).

## Language servers and formatters

| Language | LSP | Format on save |
|---|---|---|
| C, C++, CUDA | clangd (clang-tidy, background index) | clang-format |
| Python | pyright (basic), ruff | ruff (imports, then format) |
| Lua | lua_ls | stylua |
| Shell | bashls (shellcheck if present) | shfmt |
| JSON, YAML, Markdown | jsonls, yamlls | prettier |

`:Mason` shows them, `:MasonInstallAll` installs what is missing. A file is formatted with the `.clang-format`, `pyproject.toml`, `.stylua.toml`... of its project.

## Grace Hopper nodes

The home is shared between the x86_64 login nodes and the aarch64 Grace Hopper nodes: run `~/nvchad-romeo/install.sh` once on a Grace Hopper node too (in a `salloc`), and `nvim` takes the binaries of the node it runs on. Mason has no aarch64 clangd: there, load one with Spack or use the system's. This path is not tested yet: [tell me](https://github.com/wolf75222/nvchad-romeo/issues) if it breaks.
