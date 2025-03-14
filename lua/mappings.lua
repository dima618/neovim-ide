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

-- Telescope keymaps
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

map('n', '<F5>', require 'dap'.continue, { desc = 'DAP - Continue' })
map('n', '<F6>', require 'dap'.step_over, { desc = 'DAP - Step Over' })
map('n', '<F7>', require 'dap'.step_into, { desc = 'DAP - Step Into' })
map('n', '<F8>', require 'dap'.step_out, { desc = 'DAP - Step Out' })
map('n', '<leader>tb', require 'dap'.toggle_breakpoint, { desc = 'DAP - Toggle BP' })
map('n', '<leader>dui', require("dapui").toggle, { desc = "Toggle DAP UI" })

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

-- git signs
local gitsigns = require('gitsigns')
map({ 'n', 'v' }, '<leader>gb', gitsigns.blame, { desc = "Gitsigns Show Blame" })


map({ 'n', 'v' }, '<leader>glb', function()
  gitsigns.blame_line({ full = true })
end, { desc = "Gitsigns Show Current Line Blame" })

map('n', '<leader>gph', gitsigns.preview_hunk_inline, { desc = "Gitsigns Preview Hunk Inline" })
map('n', '<leader>grh', gitsigns.reset_hunk, { desc = "Gitsigns Reset Hunk" })
map('n', '<leader>gsh', gitsigns.stage_hunk, { desc = "Gitsigns Stage Hunk" })

map('v', '<leader>gsh', function()
  gitsigns.stage_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Gitsigns Stage Hunk" })
map('v', '<leader>grh', function()
  gitsigns.reset_hunk({ vim.fn.line('.'), vim.fn.line('v') })
end, { desc = "Gitsigns Reset Hunk" })


-- harpoon & telescope integration
local harpoon = require('harpoon')

local conf = require("telescope.config").values
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
  }):find()
end

map({ "n", "v" }, "<leader>hl", function() toggle_telescope(harpoon:list()) end,
  { desc = "Open harpoon window", remap = true })

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
--
