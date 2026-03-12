return {
  "levouh/tint.nvim",
  opts = {
    tint = -45, -- Darken colors, use a positive value to brighten
    saturation = 0.6, -- Saturation to preserve
    window_ignore_function = function(winid)
      local cfg = vim.api.nvim_win_get_config(winid)
      return cfg.relative ~= ""
    end,
  },
  config = function(_, opts)
    require("tint").setup(opts)
    -- When a floating terminal (e.g. lazygit) closes, tint's WinEnter/WinClosed
    -- handlers can miss the focus return to the editor window due to snacks.nvim's
    -- multi-step close sequence. This deferred untint acts as a safety net.
    vim.api.nvim_create_autocmd("TermClose", {
      callback = function()
        vim.defer_fn(function()
          local winid = vim.api.nvim_get_current_win()
          local cfg = vim.api.nvim_win_get_config(winid)
          if cfg.relative == "" then
            require("tint").untint(winid)
          end
        end, 50)
      end,
    })
  end,
}
