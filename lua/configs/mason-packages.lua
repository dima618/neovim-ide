-- List of mason packages to install which includes
-- linters, formatters, and dap
--
-- LSP servers don't need to be listed here if they're
-- configured in lspconfig.lua as mason will auto-install them.
return {
    -- dap
    "codelldb",
    "java-debug-adapter",
    "java-test",

    -- lsp
    "jdtls", -- Configured in ftplugin/java.lua so need to specify it here.
}
