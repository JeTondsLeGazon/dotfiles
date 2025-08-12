return {
  "folke/tokyonight.nvim",
  lazy = true,
  opts = {
    style = "storm",
    on_colors = function(colors)
      colors.comment = "#98999E"
      colors.documentation = "#98999E"
    end,
  },
}
