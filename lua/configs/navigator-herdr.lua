-- herdr backend for Navigator.nvim: at a split edge, move herdr pane focus.
-- Pairs with the vim-herdr-navigation herdr plugin, which forwards <C-h/j/k/l>
-- into nvim when it's the pane's foreground process.
local Herdr = require("Navigator.mux.vi"):new()

local directions = { h = "left", j = "down", k = "up", l = "right" }

function Herdr:new()
  assert(vim.env.HERDR_ENV == "1", "[Navigator] herdr is not running!")
  local bin = (vim.env.HERDR_BIN_PATH or "") ~= "" and vim.env.HERDR_BIN_PATH or "herdr"
  assert(vim.fn.executable(bin) == 1, "[Navigator] herdr binary not found!")

  -- herdr-nvim's sidebar is a headless daemon behind --remote-ui, so its inherited
  -- HERDR_PANE_ID isn't the sidebar pane; fall back to the focused pane there.
  local headless = vim.tbl_contains(vim.v.argv, "--headless")
  local target = (vim.env.HERDR_PANE_ID and not headless) and { "--pane", vim.env.HERDR_PANE_ID } or { "--current" }

  local state = { bin = bin, target = target }
  self.__index = self
  return setmetatable(state, self)
end

function Herdr:navigate(direction)
  -- herdr's CLI has no "previous pane" focus, so <C-\> stays within nvim
  local dir = directions[direction]
  if dir then
    vim.system(vim.list_extend({ self.bin, "pane", "focus", "--direction", dir }, self.target))
  end
  return self
end

return Herdr
