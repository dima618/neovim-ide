return {
  "olimorris/codecompanion.nvim",
  version = "^18.0.0",
  opts = {
    extensions = {
      spinner = {},
    },
    interactions = {
      chat = {
        adapter = "kiro",
        model = "claude-opus-4.6-1m",
        keymaps = {
          send = {
            modes = {
              n = { "<CR>", "<C-s>" },
              i = { "<C-s>", "<C-CR>" },
            },
          },
        },
        editor_context = {
          ["buffer"] = {
            opts = {
              -- Always sync the buffer by sharing its "diff"
              -- Or choose "all" to share the entire buffer
              default_params = "diff",
            },
          },
        },
      },
      inline = {
        adapter = "kiro",
        model = "claude-opus-4.6-1m"
      },
      cmd = {
        adapter = "kiro",
        model = "claude-opus-4.6-1m"
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    "franco-ruggeri/codecompanion-spinner.nvim",
  },
  lazy = false,
}
