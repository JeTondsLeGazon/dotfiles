-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("config.keymaps")
vim.api.nvim_set_keymap("i", "jk", "<Esc>", { noremap = true })
