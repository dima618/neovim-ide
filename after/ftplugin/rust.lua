local bufnr = vim.api.nvim_get_current_buf()
vim.keymap.set(
  "n",
  "<leader>a",
  function()
    vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
    -- or vim.lsp.buf.codeAction() if you don't want grouping.
  end,
  {
    silent = true,
    buffer = bufnr,
    desc = "Rustacean Code Action"
  }
)
vim.keymap.set(
  "n",
  "K", -- Override Neovim's built-in hover keymap with rustaceanvim's hover actions
  function()
    vim.cmd.RustLsp({ 'hover', 'actions' })
  end,
  {
    silent = true,
    buffer = bufnr,
    desc = "Rustacean Hover Action"
  }
)
vim.keymap.set(
  "n",
  "<leader>rt",
  function()
    vim.cmd.RustLsp('testables')
  end,
  {
    desc = "Execute Rust Testable"
  }
)
vim.keymap.set(
  "n",
  "<leader>db",
  function()
    vim.cmd.RustLsp('debug')
  end,
  {
    desc = "Rust Debug at Cursor"
  }
)
