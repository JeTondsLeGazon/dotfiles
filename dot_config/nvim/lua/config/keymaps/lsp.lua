-- LSP-related keymaps

-- Rename
vim.keymap.set("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })

-- Diagnostics
vim.keymap.set("n", "<leader>cD", "<Cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })

-- Find references
vim.keymap.set("n", "<leader>fo", "<Cmd> lua vim.lsp.buf.references()<CR>", { desc = "Find references" })
