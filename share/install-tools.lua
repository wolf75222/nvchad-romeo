-- Run by install.sh in a headless nvim: compiles the Treesitter parsers and installs the Mason tools (the LSP
-- servers and formatters of lua/configs, as :MasonInstallAll does), then waits until all are done.
local function say(msg)
  io.stdout:write("    " .. msg .. "\n")
end

require("lazy").load { plugins = { "nvim-treesitter", "mason.nvim", "nvim-lspconfig", "conform.nvim" } }

local ts = require("lazy.core.plugin").values(require("lazy.core.config").plugins["nvim-treesitter"], "opts")
local ok = require("nvim-treesitter").install(ts.ensure_installed):wait(30 * 60 * 1000)
say((ok and "ok" or "some parsers failed (:checkhealth nvim-treesitter)") .. ": " .. #ts.ensure_installed .. " parsers")

local registry = require "mason-registry"
local refreshed = false
registry.refresh(function()
  refreshed = true
end)
vim.wait(5 * 60 * 1000, function()
  return refreshed
end, 200)

local pkgs = {}
for _, spec in ipairs(require("nvchad.mason").get_pkgs()) do
  local name, version = spec:match "^([^@]+)@?(.*)$"
  local found, pkg = pcall(registry.get_package, name)
  if not found then
    say("not in Mason: " .. name)
  else
    table.insert(pkgs, pkg)
    if not pkg:is_installed() then
      pkg:install { version = version ~= "" and version or nil }
    end
  end
end
vim.wait(30 * 60 * 1000, function()
  for _, pkg in ipairs(pkgs) do
    if pkg:is_installing() then
      return false
    end
  end
  return true
end, 500)

local failed = {}
for _, pkg in ipairs(pkgs) do
  if not pkg:is_installed() then
    table.insert(failed, pkg.name)
  end
end
if #failed > 0 then
  say("failed (see :Mason and ~/.local/state/nvim/mason.log): " .. table.concat(failed, " "))
end
say(("ok: %d Mason tools"):format(#pkgs - #failed))
vim.cmd "qa!"
