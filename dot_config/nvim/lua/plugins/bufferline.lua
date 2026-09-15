return {
  "akinsho/bufferline.nvim",
  opts = function(_, opts)
    opts.options.always_show_bufferline = true
    opts.options.hover = { enabled = false }
    opts.options.show_tab_indicators = false
    opts.options.show_close_icon = false
  end,
  config = function(_, opts)
    require("bufferline").setup(opts)
    require("project_tabs").setup()
  end,
}
