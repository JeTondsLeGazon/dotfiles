return {
  "nvim-telescope/telescope.nvim",
  version = "*",
  dependencies = {
    "nvim-lua/plenary.nvim",
    -- optional but recommended
    { "nvim-telescope/telescope-fzf-native.nvim", "nvim-telescope/telescope-live-grep-args.nvim", build = "make" },
  },
  config = function()
    local telescope = require("telescope")

    -- first setup telescope
    telescope.setup({
      defaults = {
        vimgrep_arguments = {
          "rg",
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
          "--hidden",
          "--smart-case",
        },
        --- some more stuff
      },
    })

    -- then load the extension
    telescope.load_extension("live_grep_args")
  end,
}
