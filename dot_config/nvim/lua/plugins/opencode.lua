return {
  "NickvanDyke/opencode.nvim",
  dependencies = {
    -- Recommended for `ask()` and `select()`.
    -- Required for `snacks` provider.
    ---@module 'snacks' <- Loads `snacks.nvim` types for configuration intellisense.
    { "folke/snacks.nvim", opts = { input = {}, picker = {}, terminal = {} } },
  },
  config = function()
    -- Shared terminal command + opts so the plugin's auto-start and the
    -- toggle keymap reuse a single opencode terminal instance.
    local opencode_cmd = "opencode --port"
    ---@type snacks.terminal.Opts
    local snacks_terminal_opts = { win = { position = "right", enter = false } }

    ---@type opencode.Opts
    vim.g.opencode_opts = {
      -- Your configuration, if any — see `lua/opencode/config.lua`, or "goto definition" on the type or field.
      server = {
        start = function()
          require("snacks.terminal").open(opencode_cmd, snacks_terminal_opts)
        end,
      },
    }

    -- Required for `opts.events.reload`.
    vim.o.autoread = true

    -- Recommended/example keymaps.
    -- vim.keymap.set({ "n", "x" }, "<C-a>", function()
    --   require("opencode").ask("@this: ", { submit = true })
    -- end, { desc = "Ask opencode…" })
    -- vim.keymap.set({ "n", "x" }, "<C-x>", function()
    --   require("opencode").select()
    -- end, { desc = "Execute opencode action…" })
    -- Note: opencode.nvim 1.0.x removed `require("opencode").toggle()`.
    -- Toggle the embedded terminal via snacks.terminal instead.
    -- `t` mode is intentionally omitted: a <leader> map in terminal mode
    -- adds input delay to <leader> while typing in the terminal.
    vim.keymap.set({ "n" }, "<leader>ao", function()
      require("snacks.terminal").toggle(opencode_cmd, snacks_terminal_opts)
    end, { desc = "Toggle opencode" })

    -- vim.keymap.set({ "n", "x" }, "go", function()
    --   return require("opencode").operator("@this ")
    -- end, { desc = "Add range to opencode", expr = true })
    -- vim.keymap.set("n", "goo", function()
    --   return require("opencode").operator("@this ") .. "_"
    -- end, { desc = "Add line to opencode", expr = true })
    --
    vim.keymap.set("n", "<leader>au", function()
      require("opencode").command("session.half.page.up")
    end, { desc = "Scroll opencode up" })
    vim.keymap.set("n", "<leader>ad", function()
      require("opencode").command("session.half.page.down")
    end, { desc = "Scroll opencode down" })

    -- You may want these if you stick with the opinionated "<C-a>" and "<C-x>" above — otherwise consider "<leader>o…".
    -- vim.keymap.set("n", "+", "<C-a>", { desc = "Increment under cursor", noremap = true })
    -- vim.keymap.set("n", "-", "<C-x>", { desc = "Decrement under cursor", noremap = true })
  end,
}
