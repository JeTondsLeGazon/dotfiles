-- Utility keymaps: terminal, project management, runners, restarts

-- Toggle terminal
vim.keymap.set("n", "<leader>\\", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", vim.cmd.ToggleTerm, { desc = "Close terminal" })
vim.keymap.set("t", "<C-t>", "<C-\\><C-n>", { desc = "Exit terminal mode to normal mode" })

-- Project management
local project_manager = require("project_manager")
vim.keymap.set("n", "<leader>ps", project_manager.switch_project, { desc = "Switch Project (restart)" })
vim.keymap.set("n", "<leader>pf", project_manager.open_project_file, { desc = "Open File from Project" })

-- Run a command with one notification that updates as output arrives.
local next_job_id = 0

local function run_notified(command, title, strip_debug)
  next_job_id = next_job_id + 1
  local id = "runner_" .. next_job_id
  local finished = false

  local function notify(text, timeout, level)
    Snacks.notify(text, { id = id, title = title, timeout = timeout, level = level })
  end

  local function on_output(_, data)
    local text = vim.trim(table.concat(data, "\n"))
    if text == "" then
      return
    end
    if strip_debug then
      text = text:gsub("^DEBUG ", ""):gsub("\nDEBUG ", "\n")
    end
    vim.schedule(function()
      if not finished then
        notify(text, 0)
      end
    end)
  end

  local function finish(code)
    if finished then
      return
    end
    finished = true
    vim.schedule(function()
      if code == 0 then
        notify("Done!", 3000, "info")
      else
        notify("Failed (exit " .. code .. ")", 5000, "error")
      end
      -- Snacks can keep a notification open while its window is focused.
      -- Explicitly hide it so even the final error cannot remain indefinitely.
      vim.defer_fn(function()
        Snacks.notifier.hide(id)
      end, 5000)
    end)
  end

  notify("Running " .. title .. "…", 0)
  local job = vim.fn.jobstart(command, {
    stdout_buffered = false,
    stderr_buffered = false,
    on_stdout = on_output,
    on_stderr = on_output,
    on_exit = function(_, code)
      finish(code)
    end,
  })
  if job <= 0 then
    finish(job)
  end
end

vim.keymap.set("n", "<leader>kl", function()
  run_notified({ "uv", "lock", "--verbose" }, "uv lock", true)
end, { desc = "uv lock" })

vim.keymap.set("n", "<leader>kk", function()
  run_notified("ruff format . && ruff check --fix .", "ruff format + check")
end, { desc = "Format (rf + rc --fix)" })

vim.keymap.set("n", "<leader>ks", function()
  run_notified("uv sync --all-groups --all-extras && uv pip install debugpy", "uva")
end, { desc = "uva (sync and install debugpy)" })

vim.keymap.set("n", "<leader>kx", function()
  run_notified({ "ruff", "check", "--fix", "--unsafe-fixes", "." }, "rcfu")
end, { desc = "rcfu (unsafe Ruff fixes)" })

-- Restart Neovim
vim.keymap.set("n", "<leader>ur", function()
  vim.cmd("silent !nvim --headless -c 'sleep 100m' -c 'qa!'")
  vim.cmd("qa!")
end, { desc = "Restart Neovim" })

-- Restart active LSPs even when the current buffer is a terminal or dashboard.
vim.keymap.set("n", "<leader>uL", function()
  local names = {}
  for _, client in ipairs(vim.lsp.get_clients()) do
    names[client.name] = true
  end

  local active_names = vim.tbl_keys(names)
  if #active_names == 0 then
    vim.notify("No active LSP clients to restart", vim.log.levels.WARN)
    return
  end

  vim.cmd("lsp restart " .. table.concat(active_names, " "))
end, { desc = "Restart active LSPs" })
