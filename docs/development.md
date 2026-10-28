# Development

[README](../README.md) · [Usage](usage.md) · [Customize](customize.md) · [How it works](how-it-works.md) · [Troubleshooting](troubleshooting.md) · **Development**

```bash
rsync -a --exclude .git ./ romeo:nvchad-romeo/      # a working copy on ROMEO
ssh romeo '~/nvchad-romeo/install.sh && ~/nvchad-romeo/tests/check.sh'
```

- `tests/check.sh`: on an installed ROMEO account, opens C++, Python, Lua and shell files in a headless nvim with the real config (`tests/check.lua`, after `VimEnter` as in a real session) and checks Neovim 0.12, the theme and transparency, `rg`/`node`/`tree-sitter`/servers in `PATH`, Treesitter highlighting, clangd (attached, reports the error of the file), pyright, ruff, lua_ls, bashls, clang-format on save, the OSC 52 clipboard over ssh, the keys, no error at startup. Then `bash -n` and `shellcheck` on the scripts.
- To test from scratch: `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/.local/share/nvchad-romeo` first.
- New plugin versions: `:Lazy update` on ROMEO, `tests/check.sh`, then commit `nvim/lazy-lock.json`.
