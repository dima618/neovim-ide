-- Harpoon index in tabufline + sort harpoon buffers to front
local M = {}
local pinned = require("scripts.pinned-bufs")

-- Override style_buf to show harpoon number
local tb_utils = require("nvchad.tabufline.utils")
local orig_style_buf = tb_utils.style_buf
tb_utils.style_buf = function(nr, i, w)
  local result = orig_style_buf(nr, i, w)
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(nr), ":.")
    local list = harpoon:list()
    for idx = 1, list:length() do
      local item = list.items[idx]
      if item and item.value == path then
        local badge = tb_utils.txt("[" .. idx .. "]", "BufO" .. (vim.api.nvim_get_current_buf() == nr and "n" or "ff"))
        return badge .. result
      end
    end
  end
  return result
end

-- Sort harpoon buffers to the front of the tabline
function M.sort_bufs_by_harpoon()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then return end
  local bufs = vim.t.bufs or {}
  if #bufs <= 1 then return end

  local harpoon_idx = {}
  local list = harpoon:list()
  for idx = 1, list:length() do
    local item = list.items[idx]
    if item then
      harpoon_idx[item.value] = idx
    end
  end

  table.sort(bufs, function(a, b)
    local pa = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(a), ":.")
    local pb = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(b), ":.")
    local ha = harpoon_idx[pa]
    local hb = harpoon_idx[pb]
    if ha and hb then return ha < hb end
    if ha then return true end
    if hb then return false end
    return false
  end)

  vim.t.bufs = bufs
  vim.cmd.redrawtabline()
end

-- Pin harpoon buffers on enter and sort
vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local ok, harpoon = pcall(require, "harpoon")
    if not ok then return end
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":.")
    local list = harpoon:list()
    for i = 1, list:length() do
      local item = list.items[i]
      if item and item.value == path then
        pinned.pin_buf(args.buf)
        M.sort_bufs_by_harpoon()
        return
      end
    end
  end,
})

return M
