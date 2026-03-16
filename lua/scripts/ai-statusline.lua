-- CodeCompanion AI spinner for NvChad statusline
local M = {}
local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
local index = 1
local processing = false
local timer = nil

vim.api.nvim_create_autocmd("User", {
  pattern = { "CodeCompanionRequestStarted", "CodeCompanionRequestFinished" },
  callback = function(args)
    if args.match == "CodeCompanionRequestStarted" then
      processing = true
      if not timer then
        timer = vim.uv.new_timer()
        timer:start(0, 80, vim.schedule_wrap(function()
          index = (index % #spinner_symbols) + 1
          vim.cmd.redrawstatus()
        end))
      end
    else
      processing = false
      if timer then
        timer:stop()
        timer:close()
        timer = nil
      end
      vim.cmd.redrawstatus()
    end
  end,
})

function M.get()
  if processing then
    return "%#St_LspMsg# " .. spinner_symbols[index] .. " AI "
  end
  return ""
end

return M
