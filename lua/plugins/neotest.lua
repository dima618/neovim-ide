return {
    {
      'atm1020/neotest-jdtls'
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
                    require('rustaceanvim.neotest'),
                    require('neotest-jdtls')
                    -- ["neotest-java"] = function()
                    --     return require('neotest-jdtls')
                    -- end
                }
            }
        end
    },

}
