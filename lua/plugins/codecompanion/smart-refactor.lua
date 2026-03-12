local M = {}

local function collect_snippets(locations, seen)
  local parts = {}
  for _, loc in ipairs(locations) do
    local uri = loc.uri or loc.targetUri
    local range = loc.range or loc.targetSelectionRange
    if uri and range then
      local path = vim.uri_to_fname(uri)
      local lnum = range.start.line
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
          parts[#parts + 1] = string.format(
            "### %s (line %d)\n```\n%s\n```", rel, lnum + 1, table.concat(snippet, "\n")
          )
        end
      end
    end
  end
  return parts
end

function M.run()
  local bufnr = vim.api.nvim_get_current_buf()
  local win = vim.api.nvim_get_current_win()
  local params = vim.lsp.util.make_position_params(win, nil)
  local word = vim.fn.expand("<cword>")

  local ref_params = vim.deepcopy(params)
  ref_params.context = { includeDeclaration = true }

  local pending = 2
  local all_refs = {}
  local all_impls = {}
  local seen = {}

  local function on_done()
    pending = pending - 1
    if pending > 0 then return end

    local ref_parts = collect_snippets(all_refs, seen)
    local impl_parts = collect_snippets(all_impls, seen)

    if #ref_parts == 0 and #impl_parts == 0 then
      vim.notify("No references or implementations found for: " .. word, vim.log.levels.WARN)
      return
    end

    local cur_line = params.position.line
    local cur_lines = vim.api.nvim_buf_get_lines(
      bufnr, math.max(0, cur_line - 10), cur_line + 30, false
    )
    local cur_file = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(bufnr), ":.")

    local sections = {}
    if #ref_parts > 0 then
      sections[#sections + 1] = "## References / Callers\n" .. table.concat(ref_parts, "\n\n")
    end
    if #impl_parts > 0 then
      sections[#sections + 1] = "## Implementations / Overrides\n" .. table.concat(impl_parts, "\n\n")
    end

    local prompt = string.format(
      [[I've updated a function signature. Please update all callers, implementations, and overrides to match the new signature.

## Updated function in %s (around line %d)
```
%s
```

%s

Update each location to match the new function signature. Show the complete changes needed for each file.]],
      cur_file,
      cur_line + 1,
      table.concat(cur_lines, "\n"),
      table.concat(sections, "\n\n")
    )

    vim.schedule(function()
      require("codecompanion").chat({ content = prompt })
    end)
  end

  -- Get references
  vim.lsp.buf_request(bufnr, "textDocument/references", ref_params, function(err, result)
    all_refs = (not err and result) or {}
    on_done()
  end)

  -- Get implementations
  vim.lsp.buf_request(bufnr, "textDocument/implementation", params, function(err, result)
    all_impls = (not err and result) or {}
    on_done()
  end)
end

return M
