require "nvchad.mappings"

-- add yours here
local builtin = require('telescope.builtin')
local map = vim.keymap.set

-- nvim remaps
map("n", "<C-/>", "gcc", { desc = "toggle comment", remap = true })
map("v", "<C-/>", "gc", { desc = "toggle comment", remap = true })
map("v", "<Tab>", ">gv", { silent = true, desc = "Indent" })
map("v", ">", ">gv", { silent = true, desc = "Indent" })
map("v", "<S-Tab>", "<gv", { silent = true, desc = "Indent" })
map("v", "<", "<gv", { silent = true, desc = "Indent" })

map("n", ";", ":", { desc = "CMD enter command mode" })
map("i", "jk", "<ESC>")

map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = 'LSP Code Action' })
map('n', '<leader>df', vim.diagnostic.open_float, { desc = 'LSP Open Float Diagnostic' })
map("n", "<leader>rs", vim.lsp.buf.rename, { desc = 'LSP Rename Symbol' })

-- Telescope keymaps
local peek_opts = {
    jump_type = "never",
    layout_config = {
        width = function(_, max_columns, _)
            return math.max(100, math.floor(max_columns * 0.8))
        end,
        height = function(_, _, max_lines)
            return math.max(15, math.floor(max_lines * 0.4))
        end,
        preview_width = 0.8
    }
}
local peek_theme = require('telescope.themes').get_cursor(peek_opts)

map('n', '<leader>fr', builtin.lsp_references, { desc = 'Telescope LSP References' })
map('n', '<leader>fi', builtin.lsp_implementations, { desc = 'Telescope LSP Implementations' })
map('n', '<leader>fd', builtin.lsp_definitions, { desc = 'Telescope LSP Definitions' })
map('n', '<leader>ftd', builtin.lsp_type_definitions, { desc = 'Telescope LSP Type Definitions' })
map('n', '<leader>sl', '<cmd> SessionSearch <cr>', { desc = 'Open Telescope Session Lens' })
map('n', '<leader>fs', builtin.lsp_document_symbols, { desc = 'Telescope Symbols in Buffer' })

map("n", "<leader>pd", function() builtin.lsp_definitions(peek_theme) end, { desc = "Peek Definition" })
map("n", "<leader>pi", function() builtin.lsp_implementations(peek_theme) end, { desc = "Peek Implementations" })
map("n", "<leader>pr", function() builtin.lsp_references(peek_theme) end, { desc = "Peek References" })

-- Dropbar keymaps
local dropbar_api = require('dropbar.api')
map('n', '<Leader>;', dropbar_api.pick, { desc = 'Pick symbols in winbar' })
map('n', '[;', dropbar_api.goto_context_start, { desc = 'Go to start of current context' })
map('n', '];', dropbar_api.select_next_context, { desc = 'Select next context' })

-- DAP keymaps
local dap = require('dap')
map('n', '<F5>', dap.continue, { desc = 'DAP - Continue' })
map('n', '<F6>', dap.step_over, { desc = 'DAP - Step Over' })
map('n', '<F7>', dap.step_into, { desc = 'DAP - Step Into' })
map('n', '<F8>', dap.step_out, { desc = 'DAP - Step Out' })
map('n', '<leader>tb', dap.toggle_breakpoint, { desc = 'DAP - Toggle BP' })
map('n', '<space>tcb', function()
  local condition = vim.fn.input('Condition: ')
  -- if condition == '' then condition = nil end

  local hit_condition = vim.fn.input('Hit condition (optional): ')
  -- if hit_condition == '' then hit_condition = nil end

  dap.toggle_breakpoint(condition, hit_condition)
end, { desc = 'Toggle conditional breakpoint' })
map('n', '<leader>dui', require('dapui').toggle, { desc = "Toggle DAP UI" })
map('n', '<C-f>', require('dapui').eval, { desc = "DAP Eval Float", remap = true })

-- Tmux navigator remaps
map('n', '<C-h>', '<cmd> TmuxNavigateLeft <cr>', { desc = "Window Left", remap = true })
map('n', '<C-j>', '<cmd> TmuxNavigateDown <cr>', { desc = "Window Down", remap = true })
map('n', '<C-k>', '<cmd> TmuxNavigateUp <cr>', { desc = "Window Up", remap = true })
map('n', '<C-l>', '<cmd> TmuxNavigateRight <cr>', { desc = "Window Right", remap = true })
map('n', '<C-\\>', '<cmd> TmuxNavigatePrevious <cr>', { desc = "Window Previous", remap = true })

-- leap mappings
map({ 'n', 'x', 'o' }, 's', '<Plug>(leap-forward)')
map({ 'n', 'x', 'o' }, 'S', '<Plug>(leap-backward)')
map({ 'n', 'x', 'o' }, 'gs', '<Plug>(leap-from-window)', { desc = "Leap - Leap from window" })

-- Git
local gitsigns = require('gitsigns')
map({ 'n', 'v' }, '<leader>gb', gitsigns.blame, { desc = "Gitsigns Show Blame" })
map({ 'n', 'v' }, '<leader>glb', function() gitsigns.blame_line({ full = true }) end, { desc = "Gitsigns Show Current Line Blame" })
map('n', '<leader>gph', gitsigns.preview_hunk_inline, { desc = "Gitsigns Preview Hunk Inline" })
map('n', '<leader>grh', gitsigns.reset_hunk, { desc = "Gitsigns Reset Hunk" })
map('v', '<leader>grh', function()
    gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Gitsigns Reset Hunk" })

-- harpoon & telescope integration
local harpoon = require('harpoon')
-- REQUIRED
harpoon:setup()
-- REQUIRED

local conf = require("telescope.config").values

local make_finder = function()
  local paths = {}
  for _, item in ipairs(harpoon_files.items) do
    table.insert(paths, item.value)
  end

  return require("telescope.finders").new_table(
    {
      results = paths
    }
  )
end
local function toggle_telescope(harpoon_files)
    local file_paths = {}
    for _, item in ipairs(harpoon_files.items) do
        table.insert(file_paths, item.value)
    end

    require("telescope.pickers").new({}, {
        prompt_title = "Harpoon",
        finder = require("telescope.finders").new_table({
            results = file_paths,
        }),
        previewer = conf.file_previewer({}),
        sorter = conf.generic_sorter({}),
        attach_mappings = function(prompt_buffer_number, map)
            map(
                "n",
                "dd",  -- your mapping here
                function()
                    local state = require("telescope.actions.state")
                    local selected_entry = state.get_selected_entry()
                    local current_picker = state.get_current_picker(prompt_buffer_number)

                    harpoon:list():removeAt(selected_entry.index)
                    current_picker:refresh(make_finder())
                end
            )

            return true
        end
    }):find()
end

map({ "n", "v" }, "<leader>hl", function() toggle_telescope(harpoon:list()) end,
    { desc = "Open harpoon window", remap = true })
map("n", "<leader>hm", harpoon.ui.toggle_quick_menu, { desc = "Toggle harpoon quick menu" })

map({ "n", "v" }, "<leader>ha", function() harpoon:list():add() end, { desc = "Add to harpoon list" })

map({ "n", "v" }, "<leader>1", function() harpoon:list():select(1) end)
map({ "n", "v" }, "<leader>2", function() harpoon:list():select(2) end)
map({ "n", "v" }, "<leader>3", function() harpoon:list():select(3) end)
map({ "n", "v" }, "<leader>4", function() harpoon:list():select(4) end)

-- neotest
local neotest = require("neotest")
map(
    "n",
    "<leader>rt",
    function()
        neotest.run.run()
    end,
    { desc = "Run test" }
)
map(
    "n",
    "<leader>rat",
    function()
        neotest.run.run(vim.fn.expand("%"))
    end,
    { desc = "Run all test" }
)
map("n",
    "<leader>rdt",
    function()
        neotest.run.run({ strategy = "dap" })
    end,
    { desc = "Debug test" }
)
map("n", "<leader>st", neotest.run.stop, { desc = "Stop test" })
map("n", "<leader>ts", neotest.summary.toggle, { desc = "Toggle neotest summary" })

-- map({ "n", "i", "v" }, "<C-s>", "<cmd> w <cr>")

-- Scratch buffers
local snacks = require("snacks")
map("n", "<leader>.", function() snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", snacks.scratch.select, { desc = "Select Scratch Buffer" })

-- Lazygit
map("n", "<leader>lg", '<cmd>LazyGitCurrentFile<cr>', { desc = "Open lazygit window" })
