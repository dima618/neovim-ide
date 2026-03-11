return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre",
    opts = require "configs.conform",
  },
  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
      },
    },
  },
  -- {
  --     "mason-org/mason-lspconfig.nvim",
  --     opts = {},
  --     dependencies = {
  --         { "mason-org/mason.nvim", opts = {} },
  --         "neovim/nvim-lspconfig",
  --     },
  -- },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require "configs.lspconfig"
    end,
  },
  {
    "mason-org/mason-lspconfig.nvim",
    opts = {},
    dependencies = {
      { "mason-org/mason.nvim", opts = {} },
      "neovim/nvim-lspconfig",
    },
  },
  {
    "nvim-treesitter/nvim-treesitter-context",
    opts = {},
    lazy = false,
  },
  {
    "nvim-tree/nvim-tree.lua",
    opts = function(_, opts)
      opts.filters = {
        git_ignored = false,
      }
      opts.renderer.group_empty = true
    end,
  },
  {
    "nvim-telescope/telescope.nvim",
    opts = function(_, conf)
      conf.defaults.path_display = { "filename_first", "truncate" }
      conf.defaults.file_ignore_patterns = { "^.git/" }
      conf.defaults.vimgrep_arguments = {
        "rg",
        "--color=never",
        "--no-heading",
        "--with-filename",
        "--line-number",
        "--column",
        "--smart-case",
        "--hidden",
      }
      conf.pickers = {
        find_files = {
          hidden = true,
        },
      }
      return conf
    end,
  },
  {
    "NeogitOrg/neogit",
    dependencies = {
      "nvim-lua/plenary.nvim", -- required
      "sindrets/diffview.nvim", -- optional - Diff integration

      -- Only one of these is needed.
      "nvim-telescope/telescope.nvim", -- optional
      },
    },
    {
        "karb94/neoscroll.nvim",
        opts = {
            performance_mode = true,
        },
        lazy = false
    },
    {
      'mrcjkb/rustaceanvim',
      version = '^7', -- Recommended
      lazy = false, -- This plugin is already lazy
    },
    {
        'rmagatti/auto-session',
        lazy = false,

    ---enables autocomplete for opts
    ---@module "auto-session"
    ---@type AutoSession.Config
    opts = {
      suppressed_dirs = { "~/", "~/Projects", "~/Downloads", "/", "~/workplace" },
      -- log_level = 'debug',
    },
    config = function()
      require("auto-session").setup {
        pre_save_cmds = { function() require("scripts").save_pinned() end },
        post_restore_cmds = { function() require("scripts").load_pinned() end },
      }
    end,
  },
  {
    "Bekaboo/dropbar.nvim",
    -- optional, but required for fuzzy finder support
    dependencies = {
      "nvim-telescope/telescope-fzf-native.nvim",
      build = "make",
    },
  },
  {
    "mfussenegger/nvim-dap",
    lazy = false,
  },
  {
    "nvim-neotest/nvim-nio",
  },
  {
    "rcarriga/nvim-dap-ui",
    config = function()
      require("dapui").setup()
    end,
    dependencies = {
      "mfussenegger/nvim-dap",
    },
  },
  {
    url = "https://codeberg.org/andyg/leap.nvim",
    lazy = false,
  },
  {
    "ThePrimeagen/harpoon",
    branch = "harpoon2",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("harpoon").setup {
        settings = {
          save_on_toggle = true,
          sync_on_ui_close = true,
        },
      }
    end,
  },
  {
    "christoomey/vim-tmux-navigator",
    lazy = false,
  },
  {
    "ray-x/lsp_signature.nvim",
    event = "InsertEnter",
    opts = {
      -- cfg options
    },
  },
  {
    "rmagatti/goto-preview",
    dependencies = { "rmagatti/logger.nvim" },
    event = "BufEnter",
    config = true, -- necessary as per https://github.com/rmagatti/goto-preview/issues/88
  },
  {
    "joechrisellis/lsp-format-modifications.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
  },
}
