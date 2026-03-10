return {
  "mfussenegger/nvim-dap-python",
  dependencies = { "mfussenegger/nvim-dap" },
  ft = "python",
  keys = {
    { "<leader>do", "<Cmd>lua require('dap').step_over()<CR>", desc = "Step over" },
    { "<leader>dO", "<Cmd>lua require('dap').step_out()<CR>", desc = "Step out" },
  },
  config = function()
    local dap_python = require("dap-python")
    local dap = require("dap")
    -- Setup debugpy adapter - uses the python from your environment
    dap_python.setup("python")
    dap.adapters["pwa-chrome"] = {
      type = "server",
      host = "localhost",
      port = "${port}",
      executable = {
        command = vim.fn.stdpath("data") .. "/mason/bin/js-debug-adapter",
        args = { "${port}" },
      },
    }
  end,
}
