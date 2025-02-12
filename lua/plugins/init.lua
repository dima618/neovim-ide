return {
  {
    "stevearc/conform.nvim",
    -- event = 'BufWritePre', -- uncomment for format on save
    opts = require "configs.conform",
  },

  -- These are some examples, uncomment them if you want to see them work!
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim", "lua", "vimdoc",
        "html", "css"
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
    lazy = false,
  },


  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim",  -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
    },
    config = true,
    lazy = false
  },

  {
    "karb94/neoscroll.nvim",
    opts = {},
    lazy = false
  },

  {
    'gorbit99/codewindow.nvim',
    config = function()
      local codewindow = require('codewindow')
      codewindow.setup({
        auto_enable = true,
        minimap_width = 15,
      })
      codewindow.apply_default_keybinds()
    end,
    lazy = false
  },

  {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false,   -- This plugin is already lazy
  },

  {
    "olimorris/persisted.nvim",
    lazy = true,
    config = function()
      local persisted = require('persisted')
      persisted.setup({
        autoload = true,
      })
    end,
  },

  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, conf)
      require("telescope").load_extension("persisted")
      return conf
    end,
  }
}
