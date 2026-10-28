# Customize

[README](../README.md) · [Usage](usage.md) · **Customize** · [How it works](how-it-works.md) · [Troubleshooting](troubleshooting.md) · [Development](development.md)

The config is `~/nvchad-romeo/nvim`, linked as `~/.config/nvim`: edit it there, it is the [NvChad starter](https://github.com/NvChad/starter) with these defaults.

| File | |
|---|---|
| `lua/chadrc.lua` | theme, transparency, dashboard, extra Mason packages ([all options](https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua)) |
| `lua/options.lua` | Neovim options, OSC 52 clipboard |
| `lua/mappings.lua` | keys |
| `lua/plugins/init.lua` | plugins, Treesitter parsers |
| `lua/configs/lspconfig.lua` | LSP servers and their settings |
| `lua/configs/conform.lua` | formatters, format on save |

Examples:

```lua
-- lua/chadrc.lua: another theme (or <space>th), no transparency
M.base46 = { theme = "catppuccin", transparency = false }

-- lua/configs/lspconfig.lua: Fortran
vim.lsp.enable { "clangd", "pyright", "ruff", "bashls", "jsonls", "yamlls", "fortls" }

-- lua/configs/conform.lua: no format on save
format_on_save = false,

-- lua/plugins/init.lua: a plugin
{ "folke/trouble.nvim", cmd = "Trouble", opts = {} },
```

Then `:MasonInstallAll` for a new server or formatter, `:TSInstall <language>` for a new parser.

`git pull` keeps your changes unless the same lines changed upstream; `git stash && git pull && git stash pop` otherwise. `lazy-lock.json` pins the plugins: `:Lazy update` changes it.
