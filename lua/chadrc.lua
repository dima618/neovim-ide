-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(

---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "material-deep-ocean",
    transparency = true,
    -- hl_override = {
    -- 	Comment = { italic = true },
    -- 	["@comment"] = { italic = true },
    -- },
}

-- Transparency doesn't reach the statusline's rounded caps: their
-- background stays the theme's black. Clear it for every mode and block.
M.base46.hl_override = {}
for _, group in ipairs({
    "St_NormalModeSep", "St_VisualModeSep", "St_InsertModeSep", "St_TerminalModeSep",
    "St_NTerminalModeSep", "St_ReplaceModeSep", "St_ConfirmModeSep", "St_CommandModeSep",
    "St_SelectModeSep", "St_file_sep", "St_cwd_sep", "St_Pos_sep", "St_lsp_sep",
}) do
    M.base46.hl_override[group] = { bg = "NONE" }
end

M.nvdash = { load_on_startup = true }
M.ui = {
    --  tabufline = {
    --     lazyload = false
    -- }
    -- transparency = true,
    statusline = {
        theme = "minimal",
        separator_style = "round",
        order = { "mode", "file", "git", "%=", "lsp_msg", "%=", "ai", "diagnostics", "lsp", "cwd", "cursor" },
        modules = {
            ai = function()
                return require("scripts.ai-statusline").get()
            end,
        },
    }
}

M.mason = {
    pkgs = require("configs.mason-packages")
}

return M
