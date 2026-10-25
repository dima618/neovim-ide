-- If the built-in luarocks support fails (e.g. corporate SSL), fall back to system luarocks paths
if not pcall(require, "magick") then
  local ok, path = pcall(vim.fn.system, "luarocks --lua-version=5.1 path --lr-path 2>/dev/null")
  if ok and vim.v.shell_error == 0 then package.path = package.path .. ";" .. vim.trim(path) end
  local ok2, cpath = pcall(vim.fn.system, "luarocks --lua-version=5.1 path --lr-cpath 2>/dev/null")
  if ok2 and vim.v.shell_error == 0 then package.cpath = package.cpath .. ";" .. vim.trim(cpath) end
end

return {
  "3rd/image.nvim",
  ft = "markdown",
  opts = {
    backend = "kitty",
    integrations = {
      markdown = {
        enabled = true,
        clear_in_insert_mode = true,
      },
    },
    max_width_window_percentage = 80,
    max_height_window_percentage = 80,
  },
}
