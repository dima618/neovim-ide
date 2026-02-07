require("nvchad.configs.lspconfig").defaults()
local base = require("nvchad.configs.lspconfig")


local servers = {
    html = {},
    cssls = {},
    bashls = {},
    pyright = {
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    typeCheckingMode = "basic",
                },
            },
        },
    },
    denols = {},
    vtsls = {
        root_markets = { "package.json" },
        single_file_support = false
    },
    ["postgres-language-server"] = {}
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
