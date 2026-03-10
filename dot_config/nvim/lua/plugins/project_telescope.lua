return {
  "nvim-telescope/telescope-project.nvim",
  dependencies = {
    "nvim-telescope/telescope.nvim",
    "nvim-telescope/telescope-file-browser.nvim",
  },
  n_project_selected = function(prompt_bufnr)
    local project_actions = require("telescope._extensions.project.actions")
    -- project_actions.change_working_directory(prompt_bufnr, false)
    require("harpoon.ui").nav_file(1)
  end,
}
