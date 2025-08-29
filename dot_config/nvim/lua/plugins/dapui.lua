return {
  "rcarriga/nvim-dap-ui",
  dependencies = { "mfussenegger/nvim-dap", "nvim-neotest/nvim-nio" },
  opts = {
    layouts = {
      {
        elements = { { id = "repl", size = 1 } },
        size = 15,
        position = "bottom",
      },
    },
  },
}
