-- Autocmds are automatically loaded on the VeryLazy event
-- Default autocmds that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/autocmds.lua
--
-- Add any additional autocmds here
-- with `vim.api.nvim_create_autocmd`
--
-- Or remove existing autocmds by their group name (which is prefixed with `lazyvim_` for the defaults)
-- e.g. vim.api.nvim_del_augroup_by_name("lazyvim_wrap_spell")

-- Nvim 0.12 clears push diagnostics on detach, but leaves pull diagnostics
-- (used by Ruff and Pyright) behind when a client restarts.
vim.api.nvim_create_autocmd("LspDetach", {
  group = vim.api.nvim_create_augroup("lsp_pull_diagnostic_cleanup", { clear = true }),
  callback = function(event)
    local client_id = event.data.client_id
    local client = vim.lsp.get_client_by_id(client_id)
    if not client then
      return
    end

    local prefix = ("nvim.lsp.%s.%d."):format(client.name, client_id)
    for namespace, info in pairs(vim.diagnostic.get_namespaces()) do
      if info.name and info.name:sub(1, #prefix) == prefix then
        vim.diagnostic.reset(namespace, event.buf)
      end
    end
  end,
})
