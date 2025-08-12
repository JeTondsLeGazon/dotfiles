return {
  "akinsho/git-conflict.nvim",
  version = "*",
  config = function()
    require("git-conflict").setup({
      default_mappings = false, -- disable default mappings
      default_commands = true,
      disable_diagnostics = true, -- disable diagnostics in conflict regions
    })
  end,
}
