vim.opt_local.textwidth = 130

local jdtls = require("jdtls")
local jdtls_dap = require("jdtls.dap")
local jdtls_setup = require("jdtls.setup")
local home = os.getenv("HOME")

local root_markers = { ".git", "mvnw", "gradlew", "pom.xml", "build.gradle", "Config" }
local root_dir = jdtls_setup.find_root(root_markers)

-- Bemol Init
local bemol_dir = vim.fs.find({ ".bemol" }, { upward = true, type = "directory" })[1]
local ws_folders_lsp = {}
if bemol_dir then
    local file = io.open(bemol_dir .. "/ws_root_folders", "r")
    if file then
        for line in file:lines() do
            table.insert(ws_folders_lsp, line)
        end
        file:close()
    end
end

local project_name = vim.fn.fnamemodify(bemol_dir, ":h:s?/??:gs?/?.?") .. "." .. vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspaces/" .. project_name

local path_to_jdtls = vim.fn.expand("$MASON/share/jdtls")
local path_to_jdebug = vim.fn.expand("$MASON/share/java-debug-adapter")
local path_to_jtest = vim.fn.expand("$MASON/share/java-test")

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

local path_to_jar = vim.fn.glob(path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar", true)

local bundles = {
    vim.fn.glob(path_to_jdebug .. "/com.microsoft.java.debug.plugin-*.jar", true),
}

vim.list_extend(bundles, vim.split(vim.fn.glob(path_to_jtest .. "/*.jar", true), "\n"))

-- LSP settings for Java.
local on_attach = function(_, bufnr)
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
    }
}

local corretto_17 = "/usr/lib/jvm/java-17-amazon-corretto"
local corretto_21 = "/usr/lib/jvm/java-21-amazon-corretto"

config.cmd = {
    --
    -- 				-- 💀
    "/usr/lib/jvm/java-21-amazon-corretto/bin/java", -- or '/path/to/java17_or_newer/bin/java'
    -- depends on if `java` is in your $PATH env variable and if it points to the right version.

    "-Declipse.application=org.eclipse.jdt.ls.core.id1",
    "-Dosgi.bundles.defaultStartLevel=4",
    "-Declipse.product=org.eclipse.jdt.ls.core.product",
    "-Dlog.protocol=true",
    "-Dlog.level=ALL",
    "-Xmx1g",
    "-javaagent:" .. lombok_path,
    "--add-modules=ALL-SYSTEM",
    "--add-opens",
    "java.base/java.util=ALL-UNNAMED",
    "--add-opens",
    "java.base/java.lang=ALL-UNNAMED",

    -- 💀
    "-jar",
    path_to_jar,
    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^                                       ^^^^^^^^^^^^^^
    -- Must point to the                                                     Change this to
    -- eclipse.jdt.ls installation                                           the actual version

    -- 💀
    "-configuration",
    path_to_config,
    -- ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^        ^^^^^^
    -- Must point to the                      Change to one of `linux`, `win` or `mac`
    -- eclipse.jdt.ls installation            Depending on your system.

    -- 💀
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
            runtimes = {
                {
                    name = "JavaSE-17",
                    path = corretto_17
                },
                {
                    name = "JavaSE-21",
                    path = corretto_21
                },
            }
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
config.on_init = function(client, _)
    client.notify('workspace/didChangeConfiguration', { settings = config.settings })
    for _, line in ipairs(ws_folders_lsp) do
        print("Adding workspace folder: " .. line)
        vim.lsp.buf.add_workspace_folder(line)
    end
end

local extendedClientCapabilities = require 'jdtls'.extendedClientCapabilities
extendedClientCapabilities.resolveAdditionalTextEditsSupport = true

config.init_options = {
    bundles = bundles,
    extendedClientCapabilities = extendedClientCapabilities,
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

-- Test keymaps
local test_config = {
    vmArgs = "-ea -javaagent:/home/ilindmit/.jmockit.jar -Dmagnolio.islocalfleet=true",
    javaExec = "/usr/lib/jvm/java-17-amazon-corretto.x86_64/bin/java"
}

map('n', '<leader>dc', function()
    require 'jdtls'.test_class({
        config_overrides = test_config
    })
end, { desc = "Debug Test Class (DAP)", remap = true })
map('n', '<leader>dt', function()
    require 'jdtls'.test_nearest_method({
        config_overrides = test_config
    })
end, { desc = "Debug Nearest Method (DAP)", remap = true })
