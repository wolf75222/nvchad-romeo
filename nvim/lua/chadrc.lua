-- NvChad settings: same structure as https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua

---@type ChadrcConfig
local M = {}

M.base46 = {
  theme = "github_dark", -- <leader>th to pick another one
  transparency = true,
  hl_override = {
    Comment = { italic = true },
    ["@comment"] = { italic = true },
  },
}

M.nvdash = { load_on_startup = true }

M.mason = {
  -- installed by :MasonInstallAll on top of the LSP servers and formatters of lua/configs
  pkgs = {},
  -- no linux arm64 build of clangd in Mason: on the Grace Hopper nodes, use the clangd of the system or Spack
  skip = vim.uv.os_uname().machine == "aarch64" and { "clangd" } or {},
}

return M
