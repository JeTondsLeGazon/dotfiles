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
          dap_args.justMyCode = false
          require("neotest").run.run({ strategy = "dap" })
          -- Restore after DAP has read the config
          vim.defer_fn(function()
            dap_args.justMyCode = true
          end, 1000)
        end,
        desc = "Debug nearest test (step into libraries)",
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
