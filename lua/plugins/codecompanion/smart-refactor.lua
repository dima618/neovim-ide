local M = {}

function M.run()
  local params = vim.lsp.util.make_position_params()
  local word = vim.fn.expand("<cword>")

  vim.lsp.buf_request(0, "textDocument/references", params, function(err, refs)
    if err or not refs or #refs == 0 then
      vim.notify("No references found for: " .. word, vim.log.levels.WARN)
      return
    end

    local seen = {}
    local context_parts = {}

    for _, ref in ipairs(refs) do
      local uri = ref.uri or ref.targetUri
      local path = vim.uri_to_fname(uri)
      local lnum = ref.range.start.line
      local key = path .. ":" .. lnum
      if not seen[key] then
        seen[key] = true
        local ok, lines = pcall(vim.fn.readfile, path)
        if ok then
          local start = math.max(0, lnum - 5)
          local finish = math.min(#lines - 1, lnum + 5)
          local snippet = {}
          for i = start, finish do
            snippet[#snippet + 1] = lines[i + 1]
          end
          local rel = vim.fn.fnamemodify(path, ":.")
          context_parts[#context_parts + 1] = string.format(
            "### %s (line %d)\n```\n%s\n```", rel, lnum + 1, table.concat(snippet, "\n")
          )
        end
      end
    end

    local cur_lines = vim.api.nvim_buf_get_lines(
      0, math.max(0, params.position.line - 10), params.position.line + 30, false
    )
    local cur_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":.")

    local prompt = string.format(
      [[I've updated a function signature. Please update all callers and overrides to match the new signature.

## Updated function in %s (around line %d)
```
%s
```

## References to update
%s

Update each reference to match the new function signature. Show the complete changes needed for each file.]],
      cur_file,
      params.position.line + 1,
      table.concat(cur_lines, "\n"),
      table.concat(context_parts, "\n\n")
    )

    vim.schedule(function()
      require("codecompanion").chat({ content = prompt })
    end)
  end)
end

return M
