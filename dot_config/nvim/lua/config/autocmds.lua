-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Fix for LSP diagnostics disappearing after save (format-on-save race condition)
-- When format-on-save runs, it can cause LSP diagnostics to clear before re-publishing.
-- This autocmd forces LSP to refresh diagnostics after the save completes.
vim.api.nvim_create_autocmd("BufWritePost", {
  group = vim.api.nvim_create_augroup("lsp_diagnostic_refresh", { clear = true }),
  callback = function(event)
    -- Defer the refresh to ensure formatting has completed
    vim.defer_fn(function()
      -- Get active LSP clients for this buffer
      local clients = vim.lsp.get_active_clients({ bufnr = event.buf })
      if #clients == 0 then
        return
      end

      -- Trigger a didChange notification to force LSP re-evaluation
      -- This causes the LSP server to re-publish diagnostics
      local uri = vim.uri_from_bufnr(event.buf)
      for _, client in ipairs(clients) do
        -- Send a dummy change notification to trigger re-evaluation
        -- This ensures diagnostics are republished after formatting
        if client:supports_method("textDocument/didChange") then
          local lines = vim.api.nvim_buf_get_lines(event.buf, 0, -1, false)
          client.notify("textDocument/didChange", {
            textDocument = { uri = uri, version = nil },
            contentChanges = {
              {
                range = {
                  start = { line = 0, character = 0 },
                  ["end"] = { line = #lines, character = 0 },
                },
                text = table.concat(lines, "\n"),
              },
            },
          })
        end
      end
    end, 100) -- 100ms delay to ensure formatting is done
  end,
})
