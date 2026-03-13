return {
  {
    "benlubas/molten-nvim",
    build = ":UpdateRemotePlugins",
    dependencies = { "3rd/image.nvim" },
    ft = { "python", "quarto", "markdown" },
    keys = {
      { "<leader>ji", "<cmd>MoltenInit<cr>", desc = "Molten init kernel" },
      { "<leader>jl", "<cmd>MoltenEvaluateLine<cr>", desc = "Molten eval line" },
      { "<leader>jv", ":<C-u>MoltenEvaluateVisual<cr>", mode = "v", desc = "Molten eval visual" },
      { "<leader>jr", "<cmd>MoltenReevaluateCell<cr>", desc = "Molten re-eval cell" },
      { "<leader>jd", "<cmd>MoltenDelete<cr>", desc = "Molten delete cell" },
    },
  },
  {
    "GCBallesteros/jupytext.nvim",
    opts = { style = "percent", output_extension = "auto" },
    lazy = false,
    init = function()
      vim.defer_fn(function()
        local deps = { "jupytext", "pynvim" }
        local missing = vim.tbl_filter(function(pkg)
          return vim.fn.system("pip show " .. pkg .. " 2>/dev/null"):find("Name:") == nil
        end, deps)
        if #missing > 0 then
          vim.ui.select({ "Yes", "No" }, {
            prompt = "Missing pip packages: " .. table.concat(missing, ", ") .. ". Install now?",
          }, function(choice)
            if choice == "Yes" then
              vim.cmd("!" .. "pip install " .. table.concat(missing, " "))
            end
          end)
        end
      end, 1000)
    end,
  },
}
