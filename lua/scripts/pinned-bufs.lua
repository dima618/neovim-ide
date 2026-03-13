-- VSCode-like preview buffers: auto-close buffers you only viewed, keep ones you edited
local M = {}
local pinned_bufs = {}

local function pinned_file()
  local pinned_dir = vim.fn.stdpath("data") .. "/pinned/"
  vim.fn.mkdir(pinned_dir, "p")
  local cwd = vim.fn.getcwd():gsub("[/\\]", "%%")
  return pinned_dir .. cwd .. ".json"
end

function M.save_pinned()
  local names = {}
  for buf, _ in pairs(pinned_bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then names[#names + 1] = name end
    end
  end
  vim.fn.writefile({ vim.fn.json_encode(names) }, pinned_file())
end

function M.load_pinned()
  local f = pinned_file()
  if vim.fn.filereadable(f) == 0 then return end
  local ok, names = pcall(vim.fn.json_decode, vim.fn.readfile(f)[1])
  if not ok or type(names) ~= "table" then return end
  local name_set = {}
  for _, n in ipairs(names) do name_set[n] = true end
  for _, buf in ipairs(vim.api.nvim_list_bufs()) do
    if name_set[vim.api.nvim_buf_get_name(buf)] then
      pinned_bufs[buf] = true
    end
  end
end

function M.pin_current_buf()
  pinned_bufs[vim.api.nvim_get_current_buf()] = true
end

function M.pin_buf(buf)
  pinned_bufs[buf] = true
end

function M.is_pinned(buf)
  return pinned_bufs[buf] or false
end

vim.api.nvim_create_autocmd({ "InsertEnter", "BufWritePost" }, {
  callback = function(args)
    pinned_bufs[args.buf] = true
  end,
})

vim.api.nvim_create_autocmd("BufDelete", {
  callback = function(args)
    pinned_bufs[args.buf] = nil
  end,
})

vim.api.nvim_create_user_command("BufPin", function()
  pinned_bufs[vim.api.nvim_get_current_buf()] = true
  vim.notify("Buffer pinned", vim.log.levels.INFO)
end, { desc = "Pin current buffer" })

vim.api.nvim_create_autocmd("BufLeave", {
  callback = function(args)
    local buf = args.buf
    if pinned_bufs[buf] then return end
    vim.defer_fn(function()
      if not vim.api.nvim_buf_is_valid(buf) then return end
      if buf == vim.api.nvim_get_current_buf() then return end
      if vim.bo[buf].buftype ~= "" then return end
      for _, win in ipairs(vim.api.nvim_list_wins()) do
        if vim.api.nvim_win_get_buf(win) == buf then return end
      end
      local is_jdt = vim.api.nvim_buf_get_name(buf):match("^jdt://")
      if not is_jdt and vim.bo[buf].modified then return end
      vim.api.nvim_set_option_value("buflisted", false, { buf = buf })
    end, 0)
  end,
})

return M
