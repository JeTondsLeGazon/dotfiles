-- Options are automatically loaded before lazy.nvim startup
-- Default options that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/options.lua
-- Add any additional options here
vim.api.nvim_create_autocmd("FileType", {
  pattern = "*",
  callback = function()
    vim.opt_local.formatoptions:remove({ "r", "o" })
  end,
})

-- Make warning virtual text shorter (truncate long messages)
vim.diagnostic.config({
  virtual_text = {
    format = function(diagnostic)
      if diagnostic.severity == vim.diagnostic.severity.WARN then
        local msg = diagnostic.message
        if #msg > 50 then
          return msg:sub(1, 47) .. "..."
        end
        return msg
      end
      return diagnostic.message
    end,
  },
})
