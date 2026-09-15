return {
  "folke/tokyonight.nvim",
  lazy = true,
  opts = {
    style = "night",
    transparent = true,
    on_colors = function(colors)
      colors.comment = "#98999E"
      colors.documentation = "#98999E"
    end,
    on_highlights = function(highlights, colors)
      -- Dim warning diagnostics
      highlights.DiagnosticWarn = { fg = "#7a6535" }
      highlights.DiagnosticVirtualTextWarn = { fg = "#7a6535", bg = colors.none }
      highlights.DiagnosticSignWarn = { fg = "#7a6535" }
      highlights.DiagnosticUnderlineWarn = { sp = "#7a6535", undercurl = true }
    end,
  },
}
