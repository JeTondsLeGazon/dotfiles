-- Utility keymaps: terminal, project management, runners, restarts

-- Toggle terminal
vim.keymap.set("n", "<leader>$", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", vim.cmd.ToggleTerm, { desc = "Close terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>", { desc = "Exit terminal mode to normal mode" })

-- Project management
local project_manager = require("project_manager")
vim.keymap.set("n", "<leader>ps", project_manager.switch_project, { desc = "Switch Project (restart)" })
vim.keymap.set("n", "<leader>pf", project_manager.open_project_file, { desc = "Open File from Project" })

-- uv lock (streams progress via Snacks.notify)
vim.keymap.set("n", "<leader>rl", function()
  local id = "uv_lock"
  -- timeout=0 keeps the notification visible until the job finishes
  Snacks.notify("Running uv lock…", { id = id, title = "uv lock", timeout = 0 })
  vim.fn.jobstart({ "uv", "lock", "--verbose" }, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data, _)
      local text = vim.trim(table.concat(data, "\n"))
      if text ~= "" then
        vim.schedule(function()
          Snacks.notify(text, { id = id, title = "uv lock", timeout = 0 })
        end)
      end
    end,
    on_stderr = function(_, data, _)
      local text = vim.trim(table.concat(data, "\n"))
      if text ~= "" then
        -- Strip DEBUG prefix for cleaner display
        text = text:gsub("^DEBUG ", ""):gsub("\nDEBUG ", "\n")
        vim.schedule(function()
          Snacks.notify(text, { id = id, title = "uv lock", timeout = 0 })
        end)
      end
    end,
    on_exit = function(_, code, _)
      vim.schedule(function()
        if code == 0 then
          Snacks.notify("Done!", { id = id, title = "uv lock", level = "info", timeout = 3000 })
        else
          Snacks.notify("Failed (exit " .. code .. ")", { id = id, title = "uv lock", level = "error", timeout = 5000 })
        end
      end)
    end,
  })
end, { desc = "uv lock" })

-- Ruff format + check (streams progress via Snacks.notify)
vim.keymap.set("n", "<leader>rk", function()
  local id = "ruff"
  Snacks.notify("Running ruff format + check…", { id = id, title = "ruff", timeout = 0 })
  vim.fn.jobstart("ruff format . && ruff check --fix .", {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = function(_, data, _)
      local text = vim.trim(table.concat(data, "\n"))
      if text ~= "" then
        vim.schedule(function()
          Snacks.notify(text, { id = id, title = "ruff", timeout = 0 })
        end)
      end
    end,
    on_stderr = function(_, data, _)
      local text = vim.trim(table.concat(data, "\n"))
      if text ~= "" then
        vim.schedule(function()
          Snacks.notify(text, { id = id, title = "ruff", timeout = 0 })
        end)
      end
    end,
    on_exit = function(_, code, _)
      vim.schedule(function()
        if code == 0 then
          Snacks.notify("Done!", { id = id, title = "ruff", level = "info", timeout = 3000 })
        else
          Snacks.notify("Failed (exit " .. code .. ")", { id = id, title = "ruff", level = "error", timeout = 5000 })
        end
      end)
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
