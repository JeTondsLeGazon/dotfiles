return {
  "zbirenbaum/copilot.lua",
  config = function()
    require("copilot").setup({
      panel = {
        enabled = true,
        auto_refresh = true,
      },
      suggestion = {
        enabled = true,
        auto_trigger = true,
        debounce = 75,
      },
      filetypes = {
        yaml = false, -- Disable for YAML files
        markdown = false, -- Disable for Markdown files
      },
    })
  end,
  lazy = true,
}
