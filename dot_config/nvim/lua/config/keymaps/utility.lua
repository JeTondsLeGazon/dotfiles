-- Utility keymaps: terminal, project management, runners, restarts

-- Toggle terminal
vim.keymap.set("n", "<leader>$", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", vim.cmd.ToggleTerm, { desc = "Close terminal" })

-- Project management
local project_manager = require("project_manager")
vim.keymap.set("n", "<leader>ps", project_manager.switch_project, { desc = "Switch Project (restart)" })
vim.keymap.set("n", "<leader>pf", project_manager.open_project_file, { desc = "Open File from Project" })

-- uv lock
vim.keymap.set("n", "<leader>rl", function()
  vim.notify("Running: uv lock", vim.log.levels.INFO)
  vim.fn.jobstart("uv lock", {
    on_exit = function(_, code, _)
      if code == 0 then
        vim.notify("uv lock completed successfully", vim.log.levels.INFO)
      else
        vim.notify("uv lock failed with code " .. code, vim.log.levels.ERROR)
      end
    end,
  })
end, { desc = "uv lock" })

-- Ruff format + check
vim.keymap.set("n", "<leader>rk", function()
  vim.notify("Running: ruff format + ruff check --fix", vim.log.levels.INFO)
  vim.fn.jobstart("ruff format . && ruff check --fix .", {
    on_exit = function(_, code, _)
      if code == 0 then
        vim.notify("Formatting completed successfully", vim.log.levels.INFO)
      else
        vim.notify("Formatting failed with code " .. code, vim.log.levels.ERROR)
      end
    end,
  })
end, { desc = "Format (rf + rc --fix)" })

-- Restart Neovim
vim.keymap.set("n", "<leader>ur", function()
  vim.cmd("silent !nvim --headless -c 'sleep 100m' -c 'qa!'")
  vim.cmd("qa!")
end, { desc = "Restart Neovim" })

-- Restart LSP + Enable Copilot
vim.keymap.set("n", "<leader>uL", function()
  vim.notify("Restarting LSP and enabling Copilot", vim.log.levels.INFO)
  vim.cmd("LspRestart")
  vim.cmd("Copilot enable")
  vim.notify("LSP restarted and Copilot enabled", vim.log.levels.INFO)
end, { desc = "Restart LSP + Enable Copilot" })
