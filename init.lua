vim.g.base46_cache = vim.fn.stdpath "data" .. "/base46/"
vim.g.mapleader = " "
vim.opt.clipboard = "unnamedplus"

-- bootstrap lazy and all plugins
local lazypath = vim.fn.stdpath "data" .. "/lazy/lazy.nvim"

if not vim.uv.fs_stat(lazypath) then
    local repo = "https://github.com/folke/lazy.nvim.git"
    vim.fn.system { "git", "clone", "--filter=blob:none", repo, "--branch=stable", lazypath }
end

vim.opt.rtp:prepend(lazypath)

local lazy_config = require "configs.lazy"

-- load plugins
require("lazy").setup({
    {
        "NvChad/NvChad",
        lazy = false,
        branch = "v2.5",
        import = "nvchad.plugins",
    },

    { import = "plugins" },
}, lazy_config)

-- load theme
dofile(vim.g.base46_cache .. "defaults")
dofile(vim.g.base46_cache .. "statusline")

require "options"
require "nvchad.autocmds"

vim.schedule(function()
    require "mappings"
    require "scripts"
end)

-- dap and dapui
local dap, dapui = require("dap"), require("dapui")
dap.listeners.after.event_initialized["dapui_config"] = function()
    dapui.open()
end
vim.fn.sign_define('DapBreakpoint', { text = '🔴', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapStopped', { text = '▶️', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointCondition', { text = '❓', texthl = '', linehl = '', numhl = '' })
vim.fn.sign_define('DapBreakpointRejected', { text = '❌', texthl = '', linehl = '', numhl = '' })


-- rustacean
vim.g.rustaceanvim = function()
    return {
        -- Plugin configuration
        tools = {
        },
        -- LSP configuration
        server = {
            on_attach = function(client, bufnr)
                -- you can also put keymaps in here
            end,
            cmd = { '/local/home/ilindmit/.toolbox/bin/rust-analyzer' },

            default_settings = {
                -- rust-analyzer language server configuration
                ['rust-analyzer'] = {
                    cargo = {
                        targetDir = true
                    },
                },
            },
        },
        -- DAP configuration
        dap = {
        },
    }
end

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

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = "*",
  callback = function()
    local tw = vim.opt.textwidth:get()
    vim.opt.colorcolumn = tw > 0 and tostring(tw + 1) or ""
  end
})

if vim.lsp.inlay_hint then
    vim.lsp.inlay_hint.enable(true, { 0 })
end
