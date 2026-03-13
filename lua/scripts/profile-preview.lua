-- Show a floating preview of a file with highlighted lines, save to apply, q to cancel
-- opts: { file, lines, highlight_start, highlight_count, name, on_save }
return function(opts)
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_name(buf, opts.name or ("preview://" .. opts.file))
  vim.bo[buf].buftype = "acwrite"
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, opts.lines)
  vim.bo[buf].filetype = "bash"
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    col = math.floor((vim.o.columns - width) / 2),
    row = math.floor((vim.o.lines - height) / 2),
    style = "minimal",
    border = "rounded",
    title = " Preview: " .. opts.file .. " (save to apply, q to cancel) ",
    title_pos = "center",
  })

  for offset = 0, (opts.highlight_count or 1) - 1 do
    vim.api.nvim_buf_add_highlight(buf, -1, "DiffAdd", opts.highlight_start - 1 + offset, 0, -1)
  end
  vim.api.nvim_win_set_cursor(win, { opts.highlight_start, 0 })

  vim.keymap.set("n", "q", function()
    vim.api.nvim_win_close(win, true)
    vim.api.nvim_buf_delete(buf, { force = true })
  end, { buffer = buf })

  vim.api.nvim_create_autocmd("BufWriteCmd", {
    buffer = buf,
    once = true,
    callback = function()
      local final = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
      vim.fn.writefile(final, opts.file)
      vim.api.nvim_win_close(win, true)
      vim.api.nvim_buf_delete(buf, { force = true })
      if opts.on_save then
        opts.on_save(final)
      end
    end,
  })
end
