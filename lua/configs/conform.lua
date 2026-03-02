local options = {
  formatters_by_ft = {
    -- lua = { "stylua" },
    -- css = { "prettier" },
    -- html = { "prettier" },
  },
  format_on_save = function(bufnr)
    if vim.bo[bufnr].filetype == "java" then
      return
    end
    return { timeout_ms = 500, lsp_fallback = true }
  end,
  formatters = {
    deno_fmt = {
      cwd = require("conform.util").root_file { "deno.json", "deno.jsonc" },
    },
  },
}

return options
