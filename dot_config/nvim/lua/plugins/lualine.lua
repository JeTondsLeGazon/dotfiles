return {
  "nvim-lualine/lualine.nvim",
  opts = function(_, opts)
    table.insert(opts.sections.lualine_b, 1, {
      function()
        return vim.t.project_name or ""
      end,
      cond = function()
        return vim.t.project_name ~= nil and vim.t.project_name ~= ""
      end,
    })
  end,
}
