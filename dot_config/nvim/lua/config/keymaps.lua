-- Toggle terminal
vim.keymap.set("n", "<leader>$", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })

-- Open debug console
vim.keymap.set(
  "n",
  "<leader>dd",
  "<Cmd>lua require('dapui').float_element('watches', {position='center', enter=true, width=200, height=200})<CR>",
  { desc = "Watches" }
)

-- Rename
vim.keymap.set("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })

-- Lauch DAP configurations
vim.keymap.set("n", "<leader>df", function()
  require("dap-python").setup()
  require("dap").continue()
end, { desc = "Launch configuration" })

-- Surround
vim.keymap.set("n", "<leader>ra", "<Cmd>lua require('mini.surround').add()<CR>", { desc = "Add surround" })
vim.keymap.set("v", "<leader>ra", "<Cmd>lua require('mini.surround').add()<CR>", { desc = "Add surround" })
vim.keymap.set("n", "<leader>rd", "<Cmd>lua require('mini.surround').delete()<CR>", { desc = "Delete surround" })
vim.keymap.set("n", "<leader>rr", "<Cmd>lua require('mini.surround').replace()<CR>", { desc = "Replace surround" })
