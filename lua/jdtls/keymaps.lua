-- NOTE: Java specific keymaps with which key
vim.cmd(
  "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_compile JdtCompile lua require('jdtls').compile(<f-args>)"
)
vim.cmd(
  "command! -buffer -nargs=? -complete=custom,v:lua.require'jdtls'._complete_set_runtime JdtSetRuntime lua require('jdtls').set_runtime(<f-args>)"
)
vim.cmd("command! -buffer JdtUpdateConfig lua require('jdtls').update_project_config()")
vim.cmd("command! -buffer JdtJol lua require('jdtls').jol()")
vim.cmd("command! -buffer JdtBytecode lua require('jdtls').javap()")
vim.cmd("command! -buffer JdtJshell lua require('jdtls').jshell()")

local bufnr = vim.api.nvim_get_current_buf()

local map = vim.keymap.set

map('n', '<leader>jo', require 'jdtls'.organize_imports,
  { desc = "Organize Imports", buffer = bufnr, nowait = true, remap = false })
map('n', '<leader>ju', '<Cmd>JdtUpdateConfig<CR>',
  { desc = "Update Java Config", buffer = bufnr, nowait = true, remap = false })
