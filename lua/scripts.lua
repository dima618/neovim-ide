
-- Close all buffers except the current one
vim.api.nvim_create_user_command('BufClose',
  function()
    local bufs = vim.api.nvim_list_bufs()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, i in ipairs(bufs) do
      if i ~= current_buf then
        vim.api.nvim_buf_delete(i, {})
      end
    end
  end,
  {})

-- Force close all buffers except current one (Any unsaved changes will be lost).
vim.api.nvim_create_user_command('BufCloseForce',
  function()
    local bufs = vim.api.nvim_list_bufs()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, i in ipairs(bufs) do
      if i ~= current_buf then
        vim.api.nvim_buf_delete(i, { force = true })
      end
    end
  end,
  {})

-- Remove trailing white spaces on save.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

-- Format on save
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = vim.api.nvim_create_augroup("lsp", { clear = true }),
--     callback = function(args)
--         vim.api.nvim_create_autocmd("BufWritePre", {
--             buffer = args.buf,
--             callback = function(opts)
--                 if vim.bo[opts.buf].filetype ~= 'java' then
--                     vim.lsp.buf.format { async = false, id = args.data.client_id }
--                 end
--             end,
--         })
--     end
-- })

vim.api.nvim_buf_create_user_command(0, "Format", function(_)
    vim.lsp.buf.format()
end, { desc = "Format current buffer with LSP" })
