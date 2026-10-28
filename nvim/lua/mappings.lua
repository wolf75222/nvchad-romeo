require "nvchad.mappings"

local map = vim.keymap.set

-- the same keys as LazyVim
map("n", "<leader>e", "<cmd>NvimTreeToggle<cr>", { desc = "nvimtree toggle window" })
map("n", "<leader>fg", "<cmd>Telescope live_grep<cr>", { desc = "telescope live grep" })
map("n", "<leader>fr", "<cmd>Telescope oldfiles<cr>", { desc = "telescope recent files" })
map({ "n", "x" }, "<leader>cf", function()
  require("conform").format { async = true, lsp_format = "fallback" }
end, { desc = "format file" })
map("n", "<leader>xx", "<cmd>Telescope diagnostics<cr>", { desc = "telescope diagnostics" })
map({ "n", "x" }, "<leader>ca", vim.lsp.buf.code_action, { desc = "LSP code action" })
