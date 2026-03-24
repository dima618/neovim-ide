require "nvchad.mappings"

-- add yours here
local builtin = require "telescope.builtin"
local map = vim.keymap.set

vim.keymap.del("n", "<leader>h")

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
map("n", "<leader>bp", '<cmd> BufPin <cr>', { desc = 'Pin current buffer' })

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
    preview_width = 0.8,
  },
}
local peek_theme = require("telescope.themes").get_cursor(peek_opts)

map("n", "<leader>fr", builtin.lsp_references, { desc = "Telescope LSP References" })
map("n", "<leader>fi", builtin.lsp_implementations, { desc = "Telescope LSP Implementations" })
map("n", "<leader>fd", builtin.lsp_definitions, { desc = "Telescope LSP Definitions" })
map("n", "<leader>ftd", builtin.lsp_type_definitions, { desc = "Telescope LSP Type Definitions" })
map("n", "<leader>sl", "<cmd> AutoSession search <cr>", { desc = "Open Telescope Session Lens" })
map("n", "<leader>fs", builtin.lsp_document_symbols, { desc = "Telescope Symbols in Buffer" })
map("n", "<C-n>", function()
  require("telescope").extensions.file_browser.file_browser {
    path = vim.fn.expand "%:p:h",
    select_buffer = true,
    initial_mode = "normal",
    auto_depth = true,
    hidden = true,
    prompt_path = true,
  }
end, { desc = "Telescope File Browser" })

map("n", "<leader>cf", function()
  require("telescope").extensions.file_browser.file_browser {
    path = vim.fn.expand "%:p:h",
    select_buffer = true,
    prompt_path = true,
  }
end, { desc = "Create file in current dir" })

map("n", "<leader>pd", function()
  builtin.lsp_definitions(peek_theme)
end, { desc = "Peek Definition" })
map("n", "<leader>pi", function()
  builtin.lsp_implementations(peek_theme)
end, { desc = "Peek Implementations" })
map("n", "<leader>pr", function()
  builtin.lsp_references(peek_theme)
end, { desc = "Peek References" })

-- Dropbar keymaps
local dropbar_api = require "dropbar.api"
map("n", "<Leader>;", dropbar_api.pick, { desc = "Pick symbols in winbar" })
map("n", "[;", dropbar_api.goto_context_start, { desc = "Go to start of current context" })
map("n", "];", dropbar_api.select_next_context, { desc = "Select next context" })

-- DAP keymaps
local dap = require "dap"
map("n", "<F2>", dap.run_last, { desc = "DAP - Run Last" })
map("n", "<F3>", dap.restart, { desc = "DAP - Restart" })
map("n", "<F4>", dap.terminate, { desc = "DAP - Stop" })
map("n", "<F5>", dap.continue, { desc = "DAP - Continue" })
map("n", "<F6>", dap.step_over, { desc = "DAP - Step Over" })
map("n", "<F7>", dap.step_into, { desc = "DAP - Step Into" })
map("n", "<F8>", dap.step_out, { desc = "DAP - Step Out" })
map("n", "<leader>tb", dap.toggle_breakpoint, { desc = "DAP - Toggle BP" })
map("n", "<space>tcb", function()
  local condition = vim.fn.input "Condition: "
  -- if condition == '' then condition = nil end

  local hit_condition = vim.fn.input "Hit condition (optional): "
  -- if hit_condition == '' then hit_condition = nil end

  dap.toggle_breakpoint(condition, hit_condition)
end, { desc = "Toggle conditional breakpoint" })
map("n", "<leader>dui", require("dapui").toggle, { desc = "Toggle DAP UI" })
map({ "n", "v" }, "<C-f>", require("dapui").eval, { desc = "DAP Eval Float", remap = true })

-- Tmux navigator remaps
map("n", "<C-h>", "<cmd> TmuxNavigateLeft <cr>", { desc = "Window Left", remap = true })
map("n", "<C-j>", "<cmd> TmuxNavigateDown <cr>", { desc = "Window Down", remap = true })
map("n", "<C-k>", "<cmd> TmuxNavigateUp <cr>", { desc = "Window Up", remap = true })
map("n", "<C-l>", "<cmd> TmuxNavigateRight <cr>", { desc = "Window Right", remap = true })
map("n", "<C-\\>", "<cmd> TmuxNavigatePrevious <cr>", { desc = "Window Previous", remap = true })

-- leap mappings
map({ "n", "x", "o" }, "s", "<Plug>(leap-forward)")
map({ "n", "x", "o" }, "S", "<Plug>(leap-backward)")
map({ "n", "x", "o" }, "gs", "<Plug>(leap-from-window)", { desc = "Leap - Leap from window" })

-- Git
local gitsigns = require "gitsigns"
map({ "n", "v" }, "<leader>gb", gitsigns.blame, { desc = "Gitsigns Show Blame" })
map({ "n", "v" }, "<leader>glb", function()
  gitsigns.blame_line { full = true }
end, { desc = "Gitsigns Show Current Line Blame" })
map("n", "<leader>gph", gitsigns.preview_hunk_inline, { desc = "Gitsigns Preview Hunk Inline" })
map("n", "<leader>grh", gitsigns.reset_hunk, { desc = "Gitsigns Reset Hunk" })
map("v", "<leader>grh", function()
  gitsigns.reset_hunk { vim.fn.line ".", vim.fn.line "v" }
end, { desc = "Gitsigns Reset Hunk" })

-- harpoon & telescope integration
local harpoon = require "harpoon"
-- REQUIRED
harpoon:setup()
-- REQUIRED

local function on_harpoon_change()
  local scripts = require("scripts")
  scripts.pin_current_buf()
  scripts.sort_bufs_by_harpoon()
end
harpoon:extend({
    ADD = on_harpoon_change,
    REMOVE = on_harpoon_change,
    REORDER = on_harpoon_change,
    REPLACE = on_harpoon_change
})

map({ "n", "v" }, "<leader>hl", function()
  require("scripts.harpoon-telescope").toggle_telescope()
end, { desc = "Open harpoon window", remap = true })
map("n", "<leader>hm", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, { desc = "Toggle harpoon quick menu" })

map({ "n", "v" }, "<leader>ha", function()
  harpoon:list():add()
end, { desc = "Add to harpoon list" })

for i = 1, 9 do
  map({ "n", "v" }, "<leader>" .. i, function() harpoon:list():select(i) end)
  map("n", "<leader>h" .. i, function()
    local list = harpoon:list()
    local item = { value = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":."), context = { row = 1, col = 0 } }
    list:replace_at(i, item)
    vim.notify("Harpoon [" .. i .. "] = " .. item.value, vim.log.levels.INFO)
  end, { desc = "Set harpoon slot " .. i })
end

map("n", "<leader>hr", function()
  local list = harpoon:list()
  local cur = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")
  for i, item in ipairs(list.items) do
    if item.value == cur then
      list:remove_at(i)
      vim.notify("Removed from harpoon", vim.log.levels.INFO)
      return
    end
  end
  vim.notify("Not in harpoon list", vim.log.levels.WARN)
end, { desc = "Remove current buffer from harpoon" })

map("n", "<leader>hc", function()
  harpoon:list():clear()
  vim.notify("Harpoon list cleared", vim.log.levels.INFO)
end, { desc = "Clear harpoon list" })

-- neotest
local neotest = require "neotest"
map("n", "<leader>rt", function()
  neotest.run.run()
end, { desc = "Run test" })
map("n", "<leader>rat", function()
  neotest.run.run(vim.fn.expand "%")
end, { desc = "Run all test" })
map("n", "<leader>rdt", function()
  neotest.run.run { strategy = "dap" }
end, { desc = "Debug test" })
map("n", "<leader>st", neotest.run.stop, { desc = "Stop test" })
map("n", "<leader>ts", neotest.summary.toggle, { desc = "Toggle neotest summary" })

-- Scratch buffers
local snacks = require "snacks"
map("n", "<leader>.", function()
  snacks.scratch()
end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", snacks.scratch.select, { desc = "Select Scratch Buffer" })

-- Lazygit
map("n", "<leader>lg", "<cmd>LazyGitCurrentFile<cr>", { desc = "Open lazygit window" })

-- Tab navigation
for i = 1, 9 do
  map("n", "<leader>t" .. i, i .. "gt", { desc = "Go to tab " .. i })
end

-- CodeCompanion
map({ "n", "v" }, "<leader>ccc", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion Chat" })
map({ "n", "v" }, "<leader>cca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Actions" })
map("v", "<leader>cci", "<cmd>CodeCompanion<cr>", { desc = "CodeCompanion Inline" })
map("n", "<leader>cci", "<cmd>CodeCompanion<cr>", { desc = "CodeCompanion Inline" })
map("n", "<leader>ccr", function() require("plugins.codecompanion.smart-refactor").run() end, { desc = "Smart Refactor" })

-- Auto-add file path context when opening chat with a visual selection
vim.api.nvim_create_autocmd("User", {
  pattern = "CodeCompanionChatCreated",
  callback = function(args)
    local ctx = _G.codecompanion_current_context
    if not ctx then return end
    local bufnr = ctx
    if not vim.api.nvim_buf_is_valid(bufnr) then return end
    local name = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")
    if name == "" then return end

    local chat_buf = args.buf
    local lines = vim.api.nvim_buf_get_lines(chat_buf, 0, -1, false)
    -- Prepend file path as context if there's content (visual selection was added)
    if #lines > 1 or (lines[1] and lines[1] ~= "") then
      table.insert(lines, 1, "> From: `" .. name .. "`")
      table.insert(lines, 2, "")
      vim.api.nvim_buf_set_lines(chat_buf, 0, 0, false, { "> From: `" .. name .. "`", "" })
    end
  end,
})
