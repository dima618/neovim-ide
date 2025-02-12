require "nvchad.mappings"

-- add yours here
local builtin = require('telescope.builtin')
local map = vim.keymap.set

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")
map('n', '<leader>fr', builtin.lsp_references, { desc = 'Telescope LSP References' })
map('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Telescope LSP Implementations' })
map('n', '<leader>fd', builtin.lsp_definitions, { desc = 'Telescope LSP Definitions' })
map('n', '<leader>ftd', builtin.lsp_type_definitions, { desc = 'Telescope LSP Type Definitions' })
map('n', '<leader>df', vim.diagnostic.open_float, { desc = 'LSP Open Float Diagnostic' })
map("n", "<leader>rs", vim.lsp.buf.rename, { desc = 'LSP Rename Symbol' })
-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
