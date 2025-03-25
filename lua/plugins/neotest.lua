return {
  {
    "rcasia/neotest-java",
    ft = "java",
    dependencies = {
      "mfussenegger/nvim-jdtls",
      "mfussenegger/nvim-dap",           -- for the debugger
      "rcarriga/nvim-dap-ui",            -- recommended
      "theHamsta/nvim-dap-virtual-text", -- recommended
    },
  },
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/nvim-nio",
      "nvim-lua/plenary.nvim",
      "antoinemadec/FixCursorHold.nvim",
      "nvim-treesitter/nvim-treesitter"
    },
    config = function()
      require("neotest").setup {
        status = {
          virtual_text = true
        },
        output = { open_on_run = true },
        adapters = {
          require('rustaceanvim.neotest')
        }
      }
    end
  },

}
