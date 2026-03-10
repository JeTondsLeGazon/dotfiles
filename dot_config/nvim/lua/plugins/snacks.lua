return {
  "folke/snacks.nvim",
  opts = {
    dashboard = { enabled = false },
    picker = {
      hidden = true,
      -- ignored = true,
      matcher = {
        fuzzy = true,
        smartcase = true,
        ignorecase = true,
      },
      sources = {
        files = {
          hidden = true,
          -- ignored = true,
        },
      },
    },
    explorer = {
      auto_close = true,
    },
  },
}
