-- Check if .nvprofile is sourced in shell profile, offer to add it if not
vim.defer_fn(function()
  local nvprofile = vim.fn.stdpath("config") .. "/.nvprofile"
  local bin_dir = vim.fn.stdpath("config") .. "/bin"
  local shell = vim.env.SHELL or ""
  local is_zsh = shell:find("zsh") ~= nil
  local profile = vim.fn.expand(is_zsh and "~/.zprofile" or "~/.bash_profile")

  -- Check PATH first, then check if already in profile file
  if vim.env.PATH:find(bin_dir, 1, true) then return end
  if vim.fn.filereadable(profile) == 1 then
    for _, line in ipairs(vim.fn.readfile(profile)) do
      if line:find(".nvprofile", 1, true) then return end
    end
  end

  vim.ui.select({ "Yes", "No" }, {
    prompt = ".nvprofile is not sourced in your shell profile. Add it?",
  }, function(choice)
    if choice ~= "Yes" then return end
    local source_line = 'source "' .. nvprofile .. '"'
    local lines = vim.fn.readfile(profile)

    -- Insert after the source rc block, or append if not found
    local pattern = is_zsh and "source.*zshrc" or "^fi$"
    local rc_pattern = is_zsh and "zshrc" or "bashrc"
    local inserted = false
    local in_rc_block = false
    local insert_at = nil
    for i, line in ipairs(lines) do
      if line:find(rc_pattern, 1, true) then
        in_rc_block = true
      end
      if in_rc_block and line:match(pattern) then
        table.insert(lines, i + 1, "")
        table.insert(lines, i + 2, "# Neovim environment")
        table.insert(lines, i + 3, source_line)
        insert_at = i + 1
        inserted = true
        break
      end
    end
    if not inserted then
      insert_at = #lines + 1
      table.insert(lines, "")
      table.insert(lines, "# Neovim environment")
      table.insert(lines, source_line)
    end

    -- Show preview in a floating buffer
    local buf = vim.api.nvim_create_buf(false, true)
    vim.api.nvim_buf_set_name(buf, "nvprofile://" .. profile)
    vim.bo[buf].buftype = "acwrite"
    vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)
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
      title = " Preview: " .. profile .. " (save to apply, :q to cancel) ",
      title_pos = "center",
    })

    -- Highlight inserted lines and jump to them
    for offset = 0, 2 do
      vim.api.nvim_buf_add_highlight(buf, -1, "DiffAdd", insert_at - 1 + offset, 0, -1)
    end
    vim.api.nvim_win_set_cursor(win, { insert_at, 0 })

    -- Write to the actual profile on save, close on quit
    vim.api.nvim_create_autocmd("BufWriteCmd", {
      buffer = buf,
      once = true,
      callback = function()
        local final = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
        vim.fn.writefile(final, profile)
        vim.api.nvim_win_close(win, true)
        vim.api.nvim_buf_delete(buf, { force = true })
      end,
    })
  end)
end, 1000)
