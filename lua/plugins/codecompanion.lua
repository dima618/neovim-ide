return {
  "olimorris/codecompanion.nvim",
  version = "^18.0.0",
  opts = {
    interactions = {
      chat = {
        adapter = "kiro",
        model = "claude-opus-4.6-1m"
      },
      inline = {
        adapter = "kiro",
        model = "claude-sonnet-4.6"
      },
      cmd = {
        adapter = "kiro",
        model = "claude-sonnet-4.6"
      },
    },
  },
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
  },
  lazy = false,
}
