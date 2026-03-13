-- Check if .nvprofile is sourced in shell profile, offer to add it if not
vim.defer_fn(function()
  local nvprofile = vim.fn.stdpath "config" .. "/.nvprofile"
  local bin_dir = vim.fn.stdpath "config" .. "/bin"
  local shell = vim.env.SHELL or ""
  local is_zsh = shell:find "zsh" ~= nil
  local profile = vim.fn.expand(is_zsh and "~/.zprofile" or "~/.bash_profile")

  -- Check PATH first, then check if already in profile file
  if vim.env.PATH:find(bin_dir, 1, true) then
    return
  end
  if vim.fn.filereadable(profile) == 1 then
    for _, line in ipairs(vim.fn.readfile(profile)) do
      if line:find(".nvprofile", 1, true) then
        return
      end
    end
  end

  vim.ui.select({ "Yes", "No" }, {
    prompt = ".nvprofile is not sourced in your shell profile. Add it?",
  }, function(choice)
    if choice ~= "Yes" then
      return
    end
    local home = vim.env.HOME or ""
    local portable_path = nvprofile:gsub("^" .. vim.pesc(home), "$HOME")
    local source_line = 'source "' .. portable_path .. '"'
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

    require("scripts.profile-preview") {
      file = profile,
      lines = lines,
      highlight_start = insert_at,
      highlight_count = 3,
    }
  end)
end, 1000)
