-- Rex backend for Navigator.nvim: at a split edge, move Rex pane focus.
-- Pairs with the navigate_* actions in ~/.config/rex/init.lua, which forward
-- <C-h/j/k/l> into nvim when it's the pane's foreground process.
local Rex = require("Navigator.mux.vi"):new()

local directions = { h = "left", j = "down", k = "up", l = "right" }

function Rex:new()
  -- Newer Rex sets only REX_BLOCK; rex accepts a block ID wherever a session goes.
  local session = vim.env.REX_SESSION or ""
  if session == "" then
    session = vim.env.REX_BLOCK or ""
  end
  assert(session ~= "", "[Navigator] rex is not running!")
  local bin_dir = vim.env.REX_BIN_DIR or ""
  local bin = bin_dir ~= "" and (bin_dir .. "/rex") or "rex"
  assert(vim.fn.executable(bin) == 1, "[Navigator] rex binary not found!")

  -- Talk to the server and session this nvim runs in, not whatever rex defaults to.
  local connection = { bin }
  if (vim.env.REX_SERVER or "") ~= "" then
    vim.list_extend(connection, { "-S", vim.env.REX_SERVER })
  end

  local state = { connection = connection, session = session }
  self.__index = self
  return setmetatable(state, self)
end

function Rex:navigate(direction)
  -- Rex has no "previous pane" focus, so <C-\> stays within nvim
  local dir = directions[direction]
  if dir then
    local args = vim.json.encode({ direction = dir })
    vim.system(vim.list_extend(vim.deepcopy(self.connection),
      { "api", "call", "-s", self.session, "session.focus_direction", args }))
  end
  return self
end

return Rex
