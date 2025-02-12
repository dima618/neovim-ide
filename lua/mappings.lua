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

map('n', '<leader>sl', '<cmd> SessionSearch <cr>', { desc = 'Open Telescope Session Lens' })

map('n', '<leader>df', vim.diagnostic.open_float, { desc = 'LSP Open Float Diagnostic' })
map("n", "<leader>rs", vim.lsp.buf.rename, { desc = 'LSP Rename Symbol' })

local dropbar_api = require('dropbar.api')
map('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
map('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
map('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")
