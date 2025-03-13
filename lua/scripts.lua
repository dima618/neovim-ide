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
