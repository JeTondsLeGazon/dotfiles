-- DAP (Debug Adapter Protocol) keymaps

-- Open debug console
vim.keymap.set(
  "n",
  "<leader>dd",
  "<Cmd>lua require('dapui').float_element('repl', {position='center', enter=true, width=200, height=200})<CR>",
  { desc = "Debug Console" }
)

-- Launch DAP configurations
vim.keymap.set("n", "<leader>df", function()
  require("dap-python").setup()
  require("dap").continue()
end, { desc = "Launch configuration" })

-- DAP stop on exceptions
vim.keymap.set("n", "<leader>dx", function()
  require("dap").set_exception_breakpoints({ "Warning", "Error", "Exception" })
end, { desc = "Stop on exceptions" })

vim.keymap.set("n", "<leader>dX", function()
  require("dap").set_exception_breakpoints({ "Notice", "Warning", "Error", "Exception" })
end, { desc = "Stop on all" })

-- Send selection to REPL
local dap = require("dap")
vim.keymap.set("x", "<leader>dy", function()
  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
  dap.repl.open()
  dap.repl.execute(table.concat(lines, "\n"))
end, { desc = "Send selection to REPL" })
