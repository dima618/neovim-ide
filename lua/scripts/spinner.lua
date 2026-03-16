-- Reusable spinner utility for buffers and statusline
local M = {}
local symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }

--- Start a spinner as virtual text on the first line of a buffer
---@param buf number buffer handle
---@param text string label to show next to spinner
---@param hl? string highlight group (default "Title")
---@return function stop call this to stop the spinner
function M.buf_spinner(buf, text, hl)
  hl = hl or "Title"
  local ns = vim.api.nvim_create_namespace("")
  local idx = 1
  local timer = vim.uv.new_timer()
  timer:start(0, 80, vim.schedule_wrap(function()
    if not vim.api.nvim_buf_is_valid(buf) then
      timer:stop()
      timer:close()
      return
    end
    idx = (idx % #symbols) + 1
    vim.api.nvim_buf_clear_namespace(buf, ns, 0, 1)
    vim.api.nvim_buf_set_extmark(buf, ns, 0, 0, {
      virt_text = { { symbols[idx] .. " " .. text, hl } },
      virt_text_pos = "overlay",
    })
  end))

  return function()
    timer:stop()
    timer:close()
    if vim.api.nvim_buf_is_valid(buf) then
      vim.api.nvim_buf_clear_namespace(buf, ns, 0, 1)
    end
  end
end

--- Get the current spinner frame (for statusline use)
---@return string symbol
function M.frame()
  -- Shared rotating index driven by anyone calling M.tick()
  M._idx = ((M._idx or 0) % #symbols) + 1
  return symbols[M._idx]
end

return M
