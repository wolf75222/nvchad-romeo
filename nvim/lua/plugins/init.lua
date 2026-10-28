return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },

  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-tree/nvim-tree.lua",
    opts = { git = { ignore = false } }, -- show the files of .gitignore (build/, ...)
  },

  {
    "mason-org/mason.nvim",
    opts = function()
      local opts = require "nvchad.configs.mason"
      opts.install_root_dir = vim.fn.stdpath "data" .. "/mason-" .. vim.uv.os_uname().machine
      return opts
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      install_dir = vim.fn.stdpath "data" .. "/site-" .. vim.uv.os_uname().machine,
      ensure_installed = {
        "bash", "c", "cpp", "cmake", "cuda", "diff", "dockerfile", "fortran",
        "git_config", "gitcommit", "gitignore", "json", "lua", "luadoc", "make",
        "markdown", "markdown_inline", "printf", "python", "query", "regex",
        "toml", "vim", "vimdoc", "yaml",
      },
    },
  },
}
