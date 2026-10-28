# Development

[README](../README.md) · [Usage](usage.md) · [Customize](customize.md) · [How it works](how-it-works.md) · [Troubleshooting](troubleshooting.md) · **Development**

```bash
rsync -a --exclude .git ./ romeo:nvchad-romeo/      # a working copy on ROMEO
ssh romeo '~/nvchad-romeo/install.sh && ~/nvchad-romeo/tests/check.sh'
python tests/demo.py record                        # records a real run for the GIF (reinstalls on ROMEO)
python tests/demo.py render                        # draws img/nvchad-romeo.gif
```

- `tests/check.sh`: on an installed ROMEO account, opens C++, Python, Lua and shell files in a headless nvim with the real config (`tests/check.lua`, after `VimEnter` as in a real session) and checks Neovim 0.12, the theme and transparency, `rg`/`node`/`tree-sitter`/servers in `PATH`, Treesitter highlighting, clangd (attached, reports the error of the file), pyright, ruff, lua_ls, bashls, clang-format on save, the OSC 52 clipboard over ssh, the keys, no error at startup. Then `bash -n` and `shellcheck` on the scripts.
- `tests/demo.py`: runs bash in a pseudo-terminal, types the install command of the README (after removing nvchad-romeo from the ROMEO account), then `ssh -t romeo 'cd heat && nvim'` on a small C++ project it writes: Telescope, the error clangd reports and its fix, completion, clang-format on save, the file tree. The screen is kept with pyte and drawn with Pillow in a Nerd Font (JetBrainsMono Nerd Font); a stand-in `ssh` hides the post-quantum warnings of OpenSSH. `--no-install` records only the nvim part. Needs `pyte` and `Pillow`.
- `tests/tui.py` (a program in a pseudo-terminal, its screen drawn as PNG) comes from [RSV](https://github.com/wolf75222/RSV) and [dsh-romeo](https://github.com/wolf75222/dsh-romeo), with the cursor, the Powerline separators of the statusline drawn as shapes, and the 24-bit color answer Neovim asks for.
- To test from scratch: `rm -rf ~/.local/share/nvim ~/.local/state/nvim ~/.cache/nvim ~/.local/share/nvchad-romeo` first.
- New plugin versions: `:Lazy update` on ROMEO, `tests/check.sh`, then commit `nvim/lazy-lock.json`.
