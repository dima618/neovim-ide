-- Prompt user to select a notes directory via telescope, then offer to save it
local M = function()
  require("telescope").load_extension "file_browser"
  require("telescope").extensions.file_browser.file_browser {
    prompt_title = "Select Notes Folder (<C-s> to confirm)",
    path = vim.env.HOME,
    cwd = vim.env.HOME,
    follow_symlinks = true,
    hidden = false,
    respect_gitignore = false,
    select_buffer = false,
    dir_icon = "",
    grouped = true,
    files = false,
    attach_mappings = function(_, map)
      local action_state = require "telescope.actions.state"
      local fb_actions = require "telescope._extensions.file_browser.actions"

      -- Use <C-s> to select the current browsing directory
      map({ "i", "n" }, "<C-s>", function(prompt_bufnr)
        local finder = action_state.get_current_picker(prompt_bufnr).finder
        local dir = finder.path
        require("telescope.actions").close(prompt_bufnr)
        vim.cmd("cd " .. vim.fn.fnameescape(dir))
        vim.ui.select({ "Yes", "No" }, {
          prompt = "Set " .. dir .. " as your notes directory?",
        }, function(choice)
          if choice ~= "Yes" then
            return
          end
          local nvprofile = vim.fn.stdpath "config" .. "/.nvprofile.local"
          if vim.fn.filereadable(nvprofile) == 0 then
            vim.fn.writefile({}, nvprofile)
          end
          local home = vim.env.HOME or ""
          local portable_dir = dir:gsub("^" .. vim.pesc(home), "$HOME")
          local export_line = 'export NOTES_DIRECTORY="' .. portable_dir .. '"'
          local lines = vim.fn.readfile(nvprofile)

          local insert_at = nil
          for i, line in ipairs(lines) do
            if line:find("NOTES_DIRECTORY", 1, true) then
              lines[i] = export_line
              insert_at = i
              break
            end
          end
          if not insert_at then
            insert_at = #lines + 1
            table.insert(lines, export_line)
          end

          require("scripts.profile-preview") {
            file = nvprofile,
            lines = lines,
            highlight_start = insert_at,
            on_save = function()
              vim.env.NOTES_DIRECTORY = dir
              vim.cmd("cd " .. vim.fn.fnameescape(dir))
              vim.g.auto_session_enabled = true
              require("auto-session").auto_restore_session()
              vim.notify("NOTES_DIRECTORY set. Restart your shell to apply.", vim.log.levels.INFO)
            end,
          }
        end)
      end)
      return true
    end,
  }
end

if vim.g.notes_setup then
  vim.api.nvim_create_autocmd("UIEnter", {
    once = true,
    callback = function()
      vim.schedule(M)
    end,
  })
end

return M
