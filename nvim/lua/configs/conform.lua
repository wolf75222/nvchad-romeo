local options = {
  formatters_by_ft = {
    c = { "clang-format" },
    cpp = { "clang-format" },
    cuda = { "clang-format" },
    python = { "ruff_organize_imports", "ruff_format" },
    lua = { "stylua" },
    sh = { "shfmt" },
    bash = { "shfmt" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
  },

  format_on_save = {
    timeout_ms = 1200,
    lsp_format = "fallback",
  },
}

return options
