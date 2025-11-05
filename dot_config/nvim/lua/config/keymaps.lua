-- Toggle terminal
vim.keymap.set("n", "<leader>$", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", [[<C-\><C-n>]], { desc = "Close terminal" })

-- Open debug console
vim.keymap.set(
  "n",
  "<leader>dd",
  "<Cmd>lua require('dapui').float_element('repl', {position='center', enter=true, width=200, height=200})<CR>",
  { desc = "Debug Console" }
)

-- Rename
vim.keymap.set("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })

-- Lauch DAP configurations
vim.keymap.set("n", "<leader>df", function()
  require("dap-python").setup()
  require("dap").continue()
end, { desc = "Launch configuration" })

-- DAP step functions
vim.keymap.set("n", "<leader>do", "<Cmd>lua require('dap').step_over()<CR>", { desc = "Step over" })
vim.keymap.set("n", "<leader>dO", "<Cmd>lua require('dap').step_out()<CR>", { desc = "Step out" })

-- DAP stop on exceptions
vim.keymap.set("n", "<leader>dx", function()
  require("dap").set_exception_breakpoints({ "Warning", "Error", "Exception" })
end, { desc = "Stop on exceptions" })

vim.keymap.set("n", "<leader>dX", function()
  require("dap").set_exception_breakpoints({ "Notice", "Warning", "Error", "Exception" })
end, { desc = "Stop on all" })

-- Git conflicts
vim.keymap.set("n", "<leader>go", "<Cmd>GitConflictChooseOurs<CR>", { desc = "Git conflict choose ours" })
vim.keymap.set("n", "<leader>gt", "<Cmd>GitConflictChooseTheirs<CR>", { desc = "Git conflict choose theirs" })
vim.keymap.set("n", "<leader>gC", "<Cmd>GitConflictChooseBoth<CR>", { desc = "Git conflict choose both" })
vim.keymap.set("n", "<leader>gn", "<Cmd>GitConflictNextConflict<CR>", { desc = "Git conflict next" })
vim.keymap.set("n", "<leader>gN", "<Cmd>GitConflictPrevConflict<CR>", { desc = "Git conflict previous" })

-- Send buffer to REPL
local dap = require("dap")
vim.keymap.set("x", "<leader>dy", function()
  local lines = vim.fn.getregion(vim.fn.getpos("."), vim.fn.getpos("v"))
  dap.repl.open()
  dap.repl.execute(table.concat(lines, "\n"))
end, { desc = "Send selection to REPL" })

-- Python next class or function
vim.keymap.set("n", "è", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local next_line = current_line + 1
  while next_line <= vim.api.nvim_buf_line_count(0) do
    local line = vim.api.nvim_buf_get_lines(0, next_line - 1, next_line, false)[1]
    if line:match("^%s*def ") or line:match("^%s*async def ") or line:match("^%s*class ") then
      vim.api.nvim_win_set_cursor(0, { next_line, 0 })
      vim.cmd("norm! zz")
      return
    end
    next_line = next_line + 1
  end
end, { desc = "Next class or function" })

-- Python previous class or function
vim.keymap.set("n", "ü", function()
  local current_line = vim.api.nvim_win_get_cursor(0)[1]
  local prev_line = current_line - 1
  while prev_line > 0 do
    local line = vim.api.nvim_buf_get_lines(0, prev_line - 1, prev_line, false)[1]
    if line:match("^%s*def ") or line:match("^%s*async def ") or line:match("^%s*class ") then
      vim.api.nvim_win_set_cursor(0, { prev_line, 0 })
      vim.cmd("norm! zz")
      return
    end
    prev_line = prev_line - 1
  end
end, { desc = "Previous class or function" })

-- FZF git commands
vim.keymap.set(
  "n",
  "<leader>gb",
  require("fzf-lua").git_bcommits,
  { noremap = true, silent = true, desc = "Git FZF (B)commits" }
)
vim.keymap.set(
  "n",
  "<leader>gs",
  require("fzf-lua").git_status,
  { noremap = true, silent = true, desc = "Git FZF (S)tatus" }
)

-- Snack explorer change focus
-- vim.keymap.set(
--   "n",
--   "<leader>fe",
--   "<Cmd>lua Snacks.picker.get({source='explorer'})[1].input.win:focus('list')<CR>",
--   { desc = "Snack Explorer Focus" }
-- )
vim.keymap.set("n", "<leader>fe", "<Cmd>lua Snacks.explorer.reveal({nil, 0})<CR>", { desc = "Snack Explorer Focus" })

-- Custom git diff for current file
local function show_git_file_history()
  local prev_win = vim.api.nvim_get_current_win()
  local prev_buf = vim.api.nvim_get_current_buf()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("No file detected", vim.log.levels.ERROR)
    return
  end
  local cmd = string.format("git log --oneline -- %s", vim.fn.fnameescape(file))
  local result = vim.fn.systemlist(cmd)
  if vim.v.shell_error ~= 0 then
    vim.notify("Git log failed", vim.log.levels.ERROR)
    return
  end

  -- Create commit list buffer
  local commit_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_buf_set_lines(commit_buf, 0, -1, false, result)
  vim.bo[commit_buf].filetype = "gitlog"
  vim.b.git_history_file = file

  -- Open vertical split and diff buffer
  vim.cmd("vsplit")
  local diff_win = vim.api.nvim_get_current_win()
  local diff_buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_win_set_buf(diff_win, diff_buf)
  vim.bo[diff_buf].filetype = "diff"

  -- Go back to commit list window and set buffer
  vim.cmd("wincmd p")
  local commit_win = vim.api.nvim_get_current_win()
  vim.api.nvim_win_set_buf(commit_win, commit_buf)

  local function close_git_history()
    -- Switch to previous window and buffer first
    if vim.api.nvim_win_is_valid(prev_win) then
      vim.api.nvim_set_current_win(prev_win)
      vim.api.nvim_win_set_buf(prev_win, prev_buf)
    end
    -- Now close the history windows
    if vim.api.nvim_win_is_valid(diff_win) then
      vim.api.nvim_win_close(diff_win, true)
    end
    -- if vim.api.nvim_win_is_valid(commit_win) then
    --   vim.api.nvim_win_close(commit_win, true)
    -- end
  end

  vim.keymap.set("n", "<Esc>", close_git_history, { buffer = commit_buf, noremap = true, silent = true })
  vim.keymap.set("n", "<Esc>", close_git_history, { buffer = diff_buf, noremap = true, silent = true })
  -- Function to update diff buffer
  local function update_diff()
    local line = vim.api.nvim_get_current_line()
    local commit = line:match("^(%w+)")
    if not commit then
      return
    end
    local diff = vim.fn.systemlist(string.format("git show %s -- %s", commit, vim.fn.fnameescape(file)))
    vim.api.nvim_buf_set_lines(diff_buf, 0, -1, false, diff)
  end

  -- Autocmd to update diff on cursor move
  vim.api.nvim_create_autocmd("CursorMoved", {
    buffer = commit_buf,
    callback = update_diff,
  })

  -- Initialize diff for first commit
  vim.api.nvim_set_current_win(commit_win)
  update_diff()
end

vim.keymap.set("n", "<leader>gk", show_git_file_history, { desc = "Show git file history" })
