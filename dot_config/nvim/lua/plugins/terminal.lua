return {
  "akinsho/toggleterm.nvim",
  version = "*",
  config = function()
    require("toggleterm").setup({
      shell = "zsh",
      direction = "float",
    })
  end,
}
