return {
  "ahmedkhalf/project.nvim",
  config = function()
    require("project_nvim").setup({
      -- Manual mode doesn't automatically change your root directory, so you have the option to manually do so
      -- using `:ProjectRoot` command and by pressing the bound key
      manual_mode = false,

      -- Methods of detecting the root directory. **"lsp"** and **"pattern"** set automatic scope.
      -- **"import"**, **"git_ls_files"** are optional.
      detection_methods = { "lsp", "pattern" },

      -- All the patterns used to detect root dir, when **"pattern"** is in
      -- detection_methods
      patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" },

      -- Table of lsp servers to ignore by type (to disable lsp detection set to `{}`)
      ignore_lsp = {},

      -- Don't calculate root dir on every save (lsp_ignore_methods)
      -- This is a performance optimization
      exclude_dirs = {},

      -- Show hidden files in telescope
      show_hidden = false,

      -- When set to false, you will get a message when project.nvim changes your directory.
      -- When set to true, project.nvim will be silent about it
      silent_chdir = true,

      -- What scope to change the working directory?
      -- Valid options are "global", "tab", or "win"
      scope_chdir = "global",

      -- Path where project.nvim will store the project history for use in telescope
      datapath = vim.fn.stdpath("data"),
    })
  end,
}
