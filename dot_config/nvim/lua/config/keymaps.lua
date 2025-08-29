-- Toggle terminal
vim.keymap.set("n", "<leader>$", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Close terminal" })

-- Open debug console
vim.keymap.set(
  "n",
  "<leader>dd",
  "<Cmd>lua require('dapui').float_element('repl', {position='center', enter=true, width=200, height=200})<CR>",
  { desc = "Debug Console" }
)

-- Rename
vim.keymap.set("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })

-- Lauch DAP configurations
vim.keymap.set("n", "<leader>df", function()
  require("dap-python").setup()
  require("dap").continue()
end, { desc = "Launch configuration" })

-- DAP step functions
vim.keymap.set("n", "<leader>do", "<Cmd>lua require('dap').step_over()<CR>", { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", "<Cmd>lua require('dap').step_out()<CR>", { desc = "Step out" })

-- DAP stop on exceptions
vim.keymap.set("n", "<leader>dx", function()
  require("dap").set_exception_breakpoints({ "Warning", "Error", "Exception" })
end, { desc = "Stop on exceptions" })

vim.keymap.set("n", "<leader>dX", function()
  require("dap").set_exception_breakpoints({ "Notice", "Warning", "Error", "Exception" })
end, { desc = "Stop on all" })

-- Git conflicts
vim.keymap.set("n", "<leader>go", "<Cmd>GitConflictChooseOurs<CR>", { desc = "Git conflict choose ours" })
vim.keymap.set("n", "<leader>gt", "<Cmd>GitConflictChooseTheirs<CR>", { desc = "Git conflict choose theirs" })
vim.keymap.set("n", "<leader>gC", "<Cmd>GitConflictChooseBoth<CR>", { desc = "Git conflict choose both" })
vim.keymap.set("n", "<leader>gn", "<Cmd>GitConflictNextConflict<CR>", { desc = "Git conflict next" })
vim.keymap.set("n", "<leader>gN", "<Cmd>GitConflictPrevConflict<CR>", { desc = "Git conflict previous" })

-- Copilot
vim.keymap.set(
  "n",
  "<leader>ai",
  "<Cmd>lua require('copilot.suggestion').accept()<CR>",
  { desc = "Accept Copilot suggestion" }
)
vim.keymap.set(
  "n",
  "<leader>an",
  "<Cmd>lua require('copilot.suggestion').next()<CR>",
  { desc = "Next Copilot suggestion" }
)

-- Send buffer to REPL
local dap = require("dap")
vim.keymap.set("x", "<leader>dy", function()
  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
  dap.repl.open()
  dap.repl.execute(table.concat(lines, "\n"))
end, { desc = "Send selection to REPL" })

-- Python next class or function
vim.keymap.set("n", "ü", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local next_line = current_line + 1
  while next_line <= vim.api.nvim_buf_line_count(0) do
    local line = vim.api.nvim_buf_get_lines(0, next_line - 1, next_line, false)[1]
    if line:match("^%s*def ") or line:match("^%s*async def ") or line:match("^%s*class ") then
      vim.api.nvim_win_set_cursor(0, { next_line, 0 })
      vim.cmd("norm! zz")
      return
    end
    next_line = next_line + 1
  end
end, { desc = "Next class or function" })

-- Python previous class or function
vim.keymap.set("n", "è", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local prev_line = current_line - 1
  while prev_line > 0 do
    local line = vim.api.nvim_buf_get_lines(0, prev_line - 1, prev_line, false)[1]
    if line:match("^%s*def ") or line:match("^%s*async def ") or line:match("^%s*class ") then
      vim.api.nvim_win_set_cursor(0, { prev_line, 0 })
      vim.cmd("norm! zz")
      return
    end
    prev_line = prev_line - 1
  end
end, { desc = "Previous class or function" })
