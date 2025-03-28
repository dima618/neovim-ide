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

local project_name = vim.fn.fnamemodify(root_dir, ":p:h:t")
local workspace_dir = home .. "/.cache/jdtls/workspace" .. project_name

local path_to_jdtls = require("mason-registry").get_package("jdtls"):get_install_path()
local path_to_jdebug = require("mason-registry").get_package("java-debug-adapter"):get_install_path()
local path_to_jtest = require("mason-registry").get_package("java-test"):get_install_path()

local function get_config_dir()
    if vim.fn.has('linux') == 1 then
        return '/config_linux'
    elseif vim.fn.has('mac') == 1 then
        return '/config_mac'
    else
        return '/config_win'
    end
end

local path_to_config = path_to_jdtls .. get_config_dir()
local lombok_path = path_to_jdtls .. "/lombok.jar"

-- 💀
local path_to_jar = vim.fn.glob(path_to_jdtls .. "/plugins/org.eclipse.equinox.launcher_*.jar", true)

local bundles = {
    vim.fn.glob(path_to_jdebug .. "/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
}

vim.list_extend(bundles, vim.split(vim.fn.glob(path_to_jtest .. "/extension/server/*.jar", true), "\n"))

-- LSP settings for Java.
local on_attach = function(_, bufnr)
    jdtls.setup_dap({ hotcodereplace = "auto" })
    jdtls_dap.setup_dap_main_class_configs()
    jdtls_setup.add_commands()

    -- Create a command `:Format` local to the LSP buffer
    vim.api.nvim_buf_create_user_command(bufnr, "Format", function(_)
        vim.lsp.buf.format()
    end, { desc = "Format current buffer with LSP" })

    require("lsp_signature").on_attach({
        bind = true,
        padding = "",
        handler_opts = {
            border = "rounded",
        },
        hint_prefix = "󱄑 ",
    }, bufnr)

    -- NOTE: comment out if you don't use Lspsaga
    -- require 'lspsaga'.init_lsp_saga()
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
                url = vim.fn.stdpath("config") .. "/style/java-style.xml",
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
        -- eclipse = {
        -- 	downloadSources = true,
        -- },
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
                -- flags = {
                -- 	allow_incremental_sync = true,
                -- },
            },
            useBlocks = true,
        },
        configuration = {
            runtimes = {
                {
                    name = "corretto-17",
                    path = "/usr/lib/jvm/java-17-amazon-corretto"
                },
                {
                    name = "corretto-21",
                    path = "/usr/lib/jvm/java-21-amazon-corretto"
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
require("jdtls.keymaps")
