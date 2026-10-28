-- Checks of an installed nvchad-romeo, in a headless nvim with the real config: run by tests/check.sh.
local dir = assert(vim.env.CHECK_DIR)
local failed = 0

local function check(name, cond, detail)
  if cond then
    io.stdout:write("  ok    " .. name .. "\n")
  else
    failed = failed + 1
    io.stdout:write("  FAIL  " .. name .. (detail and (": " .. detail) or "") .. "\n")
  end
end

local function open(file)
  vim.cmd("edit " .. dir .. "/" .. file)
  vim.cmd "doautocmd User FilePost" -- NvChad loads lspconfig, gitsigns... on this event (after UIEnter: none here)
  return vim.api.nvim_get_current_buf()
end

local function lsp(buf, name)
  return vim.wait(60000, function()
    local client = vim.lsp.get_clients({ bufnr = buf, name = name })[1]
    return client ~= nil and client.initialized
  end, 200)
end

check("Neovim 0.12", vim.fn.has "nvim-0.12" == 1, tostring(vim.version()))
check("theme github_dark", require("nvconfig").base46.theme == "github_dark")
check("transparent background", vim.api.nvim_get_hl(0, { name = "Normal" }).bg == nil)
for _, exe in ipairs { "rg", "node", "tree-sitter", "clangd", "pyright-langserver", "lua-language-server" } do
  check("executable " .. exe, vim.fn.executable(exe) == 1)
end

local cpp = open "main.cpp"
check("treesitter highlights C++", vim.wait(5000, function()
  return vim.treesitter.highlighter.active[cpp] ~= nil
end))
check("clangd attaches to main.cpp", lsp(cpp, "clangd"))
local diags = vim.wait(30000, function()
  return #vim.diagnostic.get(cpp) > 0
end, 200)
check("clangd reports the error of main.cpp", diags, vim.inspect(vim.diagnostic.get(cpp)))

check("pyright attaches to main.py", lsp(open "main.py", "pyright"))
check("ruff attaches to main.py", lsp(vim.api.nvim_get_current_buf(), "ruff"))
check("lua_ls attaches to main.lua", lsp(open "main.lua", "lua_ls"))
check("bashls attaches to main.sh", lsp(open "main.sh", "bashls"))

local ugly = open "ugly.cpp"
vim.cmd "silent write"
local text = table.concat(vim.api.nvim_buf_get_lines(ugly, 0, -1, false), "\n")
check("clang-format on save", text == "int main() { return 0; }", text)

vim.env.SSH_TTY = "/dev/pts/0"
dofile(vim.fn.stdpath "config" .. "/lua/options.lua")
check("clipboard through OSC 52 over ssh", vim.g.clipboard and vim.g.clipboard.name == "OSC 52")

check("<leader>e toggles the tree", vim.fn.maparg(" e", "n"):find "NvimTreeToggle" ~= nil)
check("<leader>fg greps", vim.fn.maparg(" fg", "n"):find "live_grep" ~= nil)

local msgs = vim.api.nvim_exec2("messages", { output = true }).output
check("no error at startup", not msgs:find "E%d+:" and not msgs:find "Error", msgs)

io.stdout:write(failed == 0 and "all checks passed\n" or (failed .. " checks failed\n"))
vim.cmd(failed == 0 and "qa!" or "cq!")
