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

  -- {
  --   "nvim-telescope/telescope.nvim",
  --   config = function(_, conf)
  --     conf.pickers = {
  --       current_buffer_fuzzy_find = {
  --         theme = "cursor"
  --       }
  --     }
  --     return conf
  --   end
  -- },

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
        -- auto_enable = true,
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
    'rmagatti/auto-session',
    lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { '~/', '~/Projects', '~/Downloads', '/' },
      -- log_level = 'debug',
    }
  },

  {
    'Bekaboo/dropbar.nvim',
    -- optional, but required for fuzzy finder support
    dependencies = {
      'nvim-telescope/telescope-fzf-native.nvim',
      build = 'make'
    },
  },

  {
    'mfussenegger/nvim-dap',
    lazy = false,
  },

  {
    "nvim-neotest/nvim-nio"
  },

  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
    end,
    dependencies = {
      "mfussenegger/nvim-dap"
    }
  },

  {
    "ggandor/leap.nvim",
    lazy = false
  }
}
