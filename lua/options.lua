require "nvchad.options"

-- add yours here!

local o = vim.o
o.cursorlineopt = 'both' -- to enable cursorline!

-- override nvchad indentation
o.tabstop = 4      -- A TAB character looks like 4 spaces
o.expandtab = true -- Pressing the TAB key will insert spaces instead of a TAB character
o.softtabstop = 4  -- Number of spaces inserted instead of a TAB character
o.shiftwidth = 4   -- Number of spaces inserted when indenting
o.foldmethod = 'expr'
o.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
o.foldlevel = 99
o.foldlevelstart = 99
o.foldtext = ""
vim.cmd("syntax off")
