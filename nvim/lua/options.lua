require "nvchad.options"

local o = vim.o
o.cursorlineopt = "both"
o.relativenumber = false
o.scrolloff = 4

-- Treesitter parsers and Mason tools are binaries: one copy per architecture, since the home is shared between the
-- x86_64 login nodes and the aarch64 Grace Hopper nodes.
vim.g.nvchad_romeo_arch = vim.uv.os_uname().machine
local mason_bin = vim.fn.stdpath "data" .. "/mason-" .. vim.g.nvchad_romeo_arch .. "/bin"
vim.env.PATH = mason_bin .. ":" .. vim.env.PATH

-- Over ssh there is no system clipboard: yanks go to the clipboard of your computer through the terminal (OSC 52).
-- Pasting stays inside nvim (p), or with the paste shortcut of your terminal.
if vim.env.SSH_TTY then
  local osc52 = require "vim.ui.clipboard.osc52"
  local function paste()
    return { vim.fn.split(vim.fn.getreg "", "\n"), vim.fn.getregtype "" }
  end
  vim.g.clipboard = {
    name = "OSC 52",
    copy = { ["+"] = osc52.copy "+", ["*"] = osc52.copy "*" },
    paste = { ["+"] = paste, ["*"] = paste },
  }
end
