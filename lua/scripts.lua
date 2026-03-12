-- VSCode-like preview buffers: auto-close buffers you only viewed, keep ones you edited
local pinned_bufs = {}

-- Harpoon index in tabufline: override style_buf to show harpoon number
local tb_utils = require("nvchad.tabufline.utils")
local orig_style_buf = tb_utils.style_buf
tb_utils.style_buf = function(nr, i, w)
  local result = orig_style_buf(nr, i, w)
  local ok, harpoon = pcall(require, "harpoon")
  if ok then
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(nr), ":.")
    for idx, item in ipairs(harpoon:list().items) do
      if item.value == path then
        local badge = tb_utils.txt("[" .. idx .. "]", "BufO" .. (vim.api.nvim_get_current_buf() == nr and "n" or "ff"))
        return badge .. result
      end
    end
  end
  return result
end

-- Sort harpoon buffers to the front of the tabline
local function sort_bufs_by_harpoon()
  local ok, harpoon = pcall(require, "harpoon")
  if not ok then return end
  local bufs = vim.t.bufs or {}
  if #bufs <= 1 then return end

  local harpoon_idx = {}
  for idx, item in ipairs(harpoon:list().items) do
    harpoon_idx[item.value] = idx
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

vim.api.nvim_create_autocmd("BufEnter", {
  callback = function(args)
    local ok, harpoon = pcall(require, "harpoon")
    if not ok then return end
    local path = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(args.buf), ":.")
    for _, item in ipairs(harpoon:list().items) do
      if item.value == path then
        pinned_bufs[args.buf] = true
        sort_bufs_by_harpoon()
        return
      end
    end
  end,
})

-- Close all buffers except the current one
vim.api.nvim_create_user_command('BufClose',
  function()
    local bufs = vim.api.nvim_list_bufs()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, i in ipairs(bufs) do
      if i ~= current_buf then
        vim.api.nvim_buf_delete(i, {})
      end
    end
  end,
  {})

-- Force close all buffers except current one (Any unsaved changes will be lost).
vim.api.nvim_create_user_command('BufCloseForce',
  function()
    local bufs = vim.api.nvim_list_bufs()
    local current_buf = vim.api.nvim_get_current_buf()
    for _, i in ipairs(bufs) do
      if i ~= current_buf then
        vim.api.nvim_buf_delete(i, { force = true })
      end
    end
  end,
  {})

-- Remove trailing white spaces on save.
vim.api.nvim_create_autocmd({ "BufWritePre" }, {
  pattern = { "*" },
  command = [[%s/\s\+$//e]],
})

local function pinned_file()
  local session_dir = vim.fn.stdpath("data") .. "/sessions/"
  local cwd = vim.fn.getcwd():gsub("[/\\]", "%%")
  return session_dir .. cwd .. "_pinned.json"
end

local function save_pinned()
  local names = {}
  for buf, _ in pairs(pinned_bufs) do
    if vim.api.nvim_buf_is_valid(buf) then
      local name = vim.api.nvim_buf_get_name(buf)
      if name ~= "" then names[#names + 1] = name end
    end
  end
  vim.fn.writefile({ vim.fn.json_encode(names) }, pinned_file())
end

local function load_pinned()
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

-- Format on save
-- vim.api.nvim_create_autocmd("LspAttach", {
--     group = vim.api.nvim_create_augroup("lsp", { clear = true }),
--     callback = function(args)
--         vim.api.nvim_create_autocmd("BufWritePre", {
--             buffer = args.buf,
--             callback = function(opts)
--                 if vim.bo[opts.buf].filetype ~= 'java' then
--                     vim.lsp.buf.format { async = false, id = args.data.client_id }
--                 end
--             end,
--         })
--     end
-- })

vim.api.nvim_buf_create_user_command(0, "Format", function(_)
    vim.lsp.buf.format()
end, { desc = "Format current buffer with LSP" })

local function pin_current_buf()
  pinned_bufs[vim.api.nvim_get_current_buf()] = true
end

return { save_pinned = save_pinned, load_pinned = load_pinned, sort_bufs_by_harpoon = sort_bufs_by_harpoon, pin_current_buf = pin_current_buf }
