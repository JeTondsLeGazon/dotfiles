return {
  "mfussenegger/nvim-dap-python",
  dependencies = { "mfussenegger/nvim-dap" },
  ft = "python",
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
