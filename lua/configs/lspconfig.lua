require("nvchad.configs.lspconfig").defaults()
local base = require("nvchad.configs.lspconfig")


local servers = {
    html = {},
    cssls = {},
    bashls = {},
    clangd = {
        cmd = {
            "clangd",
            "--background-index",
            "--clang-tidy",
            "--header-insertion=iwyu",
            "--completion-style=detailed",
            "--function-arg-placeholders=true",
        },
    },
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
    postgres_lsp = {}
}

for name, opts in pairs(servers) do
  vim.lsp.config(name, opts)
  vim.lsp.enable(name)
end
