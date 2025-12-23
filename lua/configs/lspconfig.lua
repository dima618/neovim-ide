-- load defaults i.e lua_lsp
require("nvchad.configs.lspconfig").defaults()

-- EXAMPLE
local servers = { "html", "cssls", "pyright", 'vtsls', 'denols' }
vim.lsp.enable(servers)

