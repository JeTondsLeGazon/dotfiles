return {
  {
    "3rd/image.nvim",
    enabled = false, -- not needed for external viewer
  },
  {
    -- Open image files in system viewer instead of inside Neovim
    dir = ".",
    name = "image-open",
    lazy = false,
    config = function()
      vim.api.nvim_create_autocmd("BufReadCmd", {
        group = vim.api.nvim_create_augroup("image_open_external", { clear = true }),
        pattern = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif", "*.bmp", "*.ico", "*.svg" },
        callback = function(event)
          local filename = vim.fn.expand("%:p")
          vim.fn.jobstart({ "xdg-open", filename }, { detach = true })
          -- Delete the buffer so you don't see binary garbage
          vim.defer_fn(function()
            if vim.api.nvim_buf_is_valid(event.buf) then
              vim.cmd("bdelete! " .. event.buf)
            end
          end, 100)
        end,
      })
    end,
  },
}
