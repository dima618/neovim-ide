local M = {}

local sync_in_progress = false

function M.sync(opts)
    if sync_in_progress then
        vim.notify("Workspace sync already in progress", vim.log.levels.WARN)
        return
    end
    sync_in_progress = true

    local root_dir = opts.root_dir
    local home = opts.home
    local config = opts.config

    local function finish_sync()
        sync_in_progress = false
    end

    local function log_error(step, err)
        vim.notify("JdtSyncWorkspace failed at " .. step .. ": " .. tostring(err), vim.log.levels.ERROR)
        finish_sync()
    end

    local cur_bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
    if not cur_bemol_dir then
        log_error("initialization", "No .bemol directory found")
        return
    end

    local brazil_root = vim.fn.fnamemodify(cur_bemol_dir, ":h")
    local cur_project_name = vim.fn.fnamemodify(cur_bemol_dir, ":h:s?/??:gs?/?.?") .. "." .. vim.fn.fnamemodify(root_dir, ":p:h:t")
    local cur_workspace_dir = home .. "/.cache/jdtls/workspaces/" .. cur_project_name

    vim.notify("Starting workspace sync...", vim.log.levels.INFO)

    for _, client in pairs(vim.lsp.get_clients({ name = "jdtls" })) do
        client.stop()
    end

    local function wait_for_jdtls_stop(callback)
        if #vim.lsp.get_clients({ name = "jdtls" }) == 0 then
            callback()
        else
            vim.defer_fn(function() wait_for_jdtls_stop(callback) end, 100)
        end
    end

    wait_for_jdtls_stop(function()
        vim.fn.jobstart("rm -rf " .. vim.fn.shellescape(cur_bemol_dir) .. " " .. vim.fn.shellescape(cur_workspace_dir), {
            on_exit = function(_, code)
                if code ~= 0 then
                    log_error("cleanup", "Exit code: " .. code)
                    return
                end

                vim.schedule(function()
                    local buf = vim.api.nvim_create_buf(false, true)
                    vim.bo[buf].modifiable = false
                    vim.bo[buf].buftype = "nofile"
                    vim.cmd('botright split')
                    local win = vim.api.nvim_get_current_win()
                    vim.api.nvim_win_set_buf(win, buf)
                    vim.api.nvim_win_set_height(win, math.floor(vim.o.lines * 0.2))

                    local spinner_symbols = { "⠋", "⠙", "⠹", "⠸", "⠼", "⠴", "⠦", "⠧", "⠇", "⠏" }
                    local spinner_idx = 1
                    local spinner_timer = vim.uv.new_timer()
                    spinner_timer:start(0, 80, vim.schedule_wrap(function()
                        if not vim.api.nvim_win_is_valid(win) then
                            spinner_timer:stop()
                            spinner_timer:close()
                            return
                        end
                        spinner_idx = (spinner_idx % #spinner_symbols) + 1
                        vim.api.nvim_set_option_value("winbar",
                            " %#DiagnosticInfo#󰴋 %#Title#" .. spinner_symbols[spinner_idx] .. " Bemol Running...",
                            { win = win })
                    end))

                    vim.fn.jobstart("bemol", {
                        cwd = brazil_root,
                        stdout_buffered = false,
                        on_stdout = function(_, data)
                            if data then
                                vim.schedule(function()
                                    vim.bo[buf].modifiable = true
                                    vim.api.nvim_buf_set_lines(buf, -1, -1, false, data)
                                    vim.bo[buf].modifiable = false
                                    if vim.api.nvim_win_is_valid(win) then
                                        vim.api.nvim_win_set_cursor(win, { vim.api.nvim_buf_line_count(buf), 0 })
                                    end
                                end)
                            end
                        end,
                        on_exit = function(_, bemol_code)
                            vim.schedule(function()
                                spinner_timer:stop()
                                spinner_timer:close()
                                if vim.api.nvim_win_is_valid(win) then
                                    vim.api.nvim_set_option_value("winbar",
                                        " %#DiagnosticOk#󱥾 %#Title#Bemol Completed",
                                        { win = win })
                                end
                            end)
                            if bemol_code ~= 0 then
                                log_error("running bemol", "Exit code: " .. bemol_code)
                                return
                            end

                            vim.schedule(function()
                                vim.notify("Restarting jdtls...", vim.log.levels.INFO)
                                require('jdtls').start_or_attach(config)
                                vim.notify("Workspace sync completed", vim.log.levels.INFO)
                                finish_sync()
                            end)
                        end
                    })
                end)
            end
        })
    end)
end

return M
