vim.opt_local.textwidth = 130

local jdtls = require("jdtls")
local jdtls_dap = require("jdtls.dap")
local jdtls_setup = require("jdtls.setup")
local home = os.getenv("HOME")

-- local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "Config" }
-- local root_dir = jdtls_setup.find_root(root_markers)
local root_dir = jdtls_setup.find_root({ "packageInfo" }, "Config")

local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
local project_name = vim.fn.fnamemodify(bemol_dir, ":h:s?/??:gs?/?.?") .. "." .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspaces/" .. project_name

local mason_path = vim.fn.stdpath("data") .. "/mason"
local path_to_jdtls = mason_path .. "/share/jdtls"
local path_to_jdebug = mason_path .. "/share/java-debug-adapter"
local path_to_jtest = mason_path .. "/share/java-test"

local function get_config_dir()
    if vim.fn.has('linux') == 1 then
        return '/config'
    elseif vim.fn.has('mac') == 1 then
        return '/config'
    else
        return '/config'
    end
end

local path_to_config = path_to_jdtls .. get_config_dir()
local lombok_path = path_to_jdtls .. "/lombok.jar"

local path_to_jar = vim.fn.glob(path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar")

local bundles = {
    vim.fn.glob(path_to_jdebug .. "/com.microsoft.java.debug.plugin-*.jar"),
}

vim.list_extend(bundles, vim.split(vim.fn.glob(path_to_jtest .. "/*.jar"), "\n"))

-- Init Bemol
local ws_folders_jdtls = {}
-- local ws_folders_lsp = {}
if bemol_dir then
    local file = io.open(bemol_dir .. "/ws_root_folders", "r")
    if file then
        for line in file:lines() do
            table.insert(ws_folders_jdtls, "file://" .. line)
            -- table.insert(ws_folders_lsp, line)
        end
        file:close()
    else
        print("Could not find bemol workspace file")
    end
end

-- LSP settings for Java.
local on_attach = function(client, bufnr)
    jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls_dap.setup_dap_main_class_configs()
    jdtls_setup.add_commands()

    require("lsp_signature").on_attach({
        bind = true,
        padding = "",
        handler_opts = {
            border = "rounded",
        },
        hint_prefix = "󱄑 ",
    }, bufnr)
end

local capabilities = {
    workspace = {
        configuration = true
    },
    textDocument = {
        completion = {
            completionItem = {
                snippetSupport = true
            }
        }
    }
}

local config = {
    flags = {
        allow_incremental_sync = true,
    },
    root_dir = root_dir
}

local java_cache_path = vim.fn.stdpath("cache") .. "/java_homes.json"

local function find_java(version)
    local candidates = {}
    local search_dirs = { "/usr/lib/jvm", "/Library/Java/JavaVirtualMachines" }
    for _, dir in ipairs(search_dirs) do
        local handle = vim.loop.fs_scandir(dir)
        if handle then
            while true do
                local name = vim.loop.fs_scandir_next(handle)
                if not name then break end
                if name:match("java%-" .. version) or name:match("jdk%-?" .. version) then
                    local path = dir .. "/" .. name
                    -- macOS JVMs have Contents/Home
                    local mac_home = path .. "/Contents/Home"
                    if vim.fn.isdirectory(mac_home) == 1 then path = mac_home end
                    if name:match("amazon%-corretto") then
                        table.insert(candidates, 1, path) -- prefer corretto
                    else
                        table.insert(candidates, path)
                    end
                end
            end
        end
    end
    return candidates[1]
end

local function load_java_homes()
    local f = io.open(java_cache_path, "r")
    if f then
        local data = vim.json.decode(f:read("*a"))
        f:close()
        -- validate cached paths still exist
        for _, v in pairs(data) do
            if vim.fn.isdirectory(v) == 0 then return nil end
        end
        return data
    end
end

local function save_java_homes(homes)
    local f = io.open(java_cache_path, "w")
    if f then
        f:write(vim.json.encode(homes))
        f:close()
    end
end

local java_homes = load_java_homes()
if not java_homes then
    java_homes = { java_17 = find_java("17"), java_21 = find_java("21") }
    save_java_homes(java_homes)
end

local java_17_home = java_homes.java_17
local java_21_home = java_homes.java_21

if not java_21_home then
    vim.notify("No Java 21 installation found", vim.log.levels.ERROR)
    return
end

config.cmd = {
    java_21_home .. "/bin/java",

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx4g",
    "-javaagent:" .. lombok_path,
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    "-jar",
    path_to_jar,
    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
    -- Must point to the                                                     Change this to
    -- eclipse.jdt.ls installation                                           the actual version

    "-configuration",
    path_to_config,
    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
    -- Must point to the                      Change to one of `linux`, `win` or `mac`
    -- eclipse.jdt.ls installation            Depending on your system.

    -- See `data directory configuration` section in the README
    "-data",
    workspace_dir,
}

config.settings = {
    java = {
        references = {
            includeDecompiledSources = true,
        },
        format = {
            enabled = true,
            settings = {
                url = vim.fn.stdpath("config") .. "/style/magnolio-eclipse.xml",
            },
        },
        eclipse = {
            downloadSources = true,
        },
        maven = {
            downloadSources = true,
        },
        signatureHelp = { enabled = true },
        contentProvider = { preferred = "fernflower" },
        -- implementationsCodeLens = {
        -- 	enabled = true,
        -- },
        completion = {
            -- favoriteStaticMembers = {
            --   "org.hamcrest.MatcherAssert.assertThat",
            --   "org.hamcrest.Matchers.*",
            --   "org.hamcrest.CoreMatchers.*",
            --   "org.junit.jupiter.api.Assertions.*",
            --   "java.util.Objects.requireNonNull",
            --   "java.util.Objects.requireNonNullElse",
            --   "org.mockito.Mockito.*",
            -- },
            -- filteredTypes = {
            --   "com.sun.*",
            --   "io.micrometer.shaded.*",
            --   "java.awt.*",
            --   "jdk.*",
            --   "sun.*",
            -- },
            -- importOrder = {
            --   "java",
            --   "javax",
            --   "com",
            --   "org",
            -- },
        },

        import = {
            exclusions = {
                -- Magnolio specific import exclusions.
                -- TODO: Can probably have a function that conditionally adds these.
                "checkstyle.thirdparty.com.google",
                "com.amazon.aws.authruntimeclient.internal.common",
                "com.amazon.coral.github.mustachejava.google",
                "com.amazon.coral.google",
                "com.amazon.magnolio.google",
                "com.amazonaws.services.dynamodbv2.local.google",
                "com.google.$common",
                "jersey.repackaged.com.google",
                "junit.framework",
            }
        },

        sources = {
            organizeImports = {
                starThreshold = 9999,
                staticStarThreshold = 9999,
            },
        },
        codeGeneration = {
            toString = {
                template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
                flags = {
                	allow_incremental_sync = true,
                },
            },
            useBlocks = true,
        },
        configuration = {
            runtimes = vim.tbl_filter(function(r) return r.path ~= nil end, {
                {
                    name = "JavaSE-17",
                    path = java_17_home
                },
                {
                    name = "JavaSE-21",
                    path = java_21_home
                },
            })
        }
        -- project = {
        -- 	referencedLibraries = {
        -- 		"**/lib/*.jar",
        -- 	},
        -- },
    },
}

config.on_attach = on_attach
config.capabilities = capabilities
config.on_init = function(_, _) end

local extendedClientCapabilities = require 'jdtls'.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

config.init_options = {
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities,
    workspaceFolders = ws_folders_jdtls
}

-- Start Server
require('jdtls').start_or_attach(config)

-- Set Java Specific Keymaps
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
map('n', '<leader>jb', '<Cmd>JdtCompile<CR>',
    { desc = "Compile Java Code", buffer = bufnr, nowait = true, remap = false })
-- Test keymaps
local function find_log4j_config()
    return vim.fs.find({ "log4j2-test.xml", "log4j2.xml" }, {
        upward = true,
        type = "file",
        path = vim.fn.expand("%:p:h"),
        stop = root_dir,
    })[1]
end

local function get_test_config()
    local vm = "-ea -javaagent:/home/ilindmit/.jmockit.jar -Dmagnolio.islocalfleet=true"
    local log4j = find_log4j_config()
    if log4j then
        vm = vm .. " -Dlog4j.configurationFile=file://" .. log4j
    end
    return {
        vmArgs = vm,
        javaExec = "/usr/lib/jvm/java-21-amazon-corretto/bin/java"
    }
end

map('n', '<leader>dc', function()
    require 'jdtls'.test_class({
        config_overrides = get_test_config()
    })
end, { desc = "Debug Test Class (DAP)", remap = true })
map('n', '<leader>dt', function()
    require 'jdtls'.test_nearest_method({
        config_overrides = get_test_config()
    })
end, { desc = "Debug Nearest Method (DAP)", remap = true })

-- JDT Build Command
vim.api.nvim_create_user_command('JdtRefreshJavaInstalls', function()
    os.remove(java_cache_path)
    java_homes = { java_17 = find_java("17"), java_21 = find_java("21") }
    save_java_homes(java_homes)
    java_17_home = java_homes.java_17
    java_21_home = java_homes.java_21
    if not java_21_home then
        vim.notify("No Java 21 installation found", vim.log.levels.ERROR)
        return
    end
    config.cmd[1] = java_21_home .. "/bin/java"
    for _, client in pairs(vim.lsp.get_clients({ name = "jdtls" })) do
        client.stop()
    end
    vim.defer_fn(function()
        require('jdtls').start_or_attach(config)
        vim.notify("Refreshed Java installs and restarted jdtls", vim.log.levels.INFO)
    end, 500)
end, { desc = "Re-discover Java installs and restart jdtls" })

vim.api.nvim_create_user_command('JdtBuildProject', jdtls.build_projects, { desc = "Rebuild project in the workspace" })
vim.api.nvim_create_user_command(
    'JdtRebuildAll',
    function()
        jdtls.build_projects({select_mode = 'all'})
    end,
    { desc = "Rebuild all projects in the workspace" }
)

-- Workspace sync command
vim.api.nvim_create_user_command('JdtSyncWorkspace', function()
    require("scripts.jdtls-sync").sync({ root_dir = root_dir, home = home, config = config })
end, { desc = "Sync workspace by removing .bemol, running bemol, and restarting jdtls" })

-- Split string on Enter: closes current string, adds `+ ""` on next line with cursor inside
local function in_java_string()
    local col = vim.fn.col(".") - 1
    local before = vim.fn.getline("."):sub(1, col)
    local in_str = false
    local i = 1
    while i <= #before do
        if before:sub(i, i) == "\\" then
            i = i + 2
        elseif before:sub(i, i) == '"' then
            in_str = not in_str
            i = i + 1
        else
            i = i + 1
        end
    end
    return in_str
end

-- Override cmp's <CR> to split strings, falling back to cmp's normal confirm/fallback chain
local cmp = require("cmp")
local luasnip = require("luasnip")
cmp.setup.buffer({
    mapping = {
        ["<CR>"] = cmp.mapping(function(fallback)
            if in_java_string() then
                local keys = vim.api.nvim_replace_termcodes('"\r+ "', true, false, true)
                vim.api.nvim_feedkeys(keys, "n", false)
            elseif cmp.visible() then
                if luasnip.expandable() then
                    luasnip.expand()
                else
                    cmp.confirm({ select = true })
                end
            else
                fallback()
            end
        end),
    },
})
