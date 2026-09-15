-- Shared table: neotest-python holds a reference to this, so mutating it
-- before a debug run changes what debugpy receives.
local dap_args = { justMyCode = true }

return {
  {
    "nvim-neotest/neotest",
    dependencies = {
      "nvim-neotest/neotest-python",
      "nvim-treesitter/nvim-treesitter",
    },
    keys = {
      {
        "<leader>dT",
        function()
          require("neotest").run.run({ strategy = "dap" })
        end,
        desc = "Debug nearest test",
      },
    },
    opts = {
      quickfix = {
        open = false,
      },
      adapters = {
        ["neotest-python"] = {
          dap = dap_args,
          runner = "pytest",
        },
      },
    },
  },
}
