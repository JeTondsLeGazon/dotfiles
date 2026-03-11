-- Toggle terminal
vim.keymap.set("n", "<leader>$", vim.cmd.ToggleTerm, { desc = "Toggle terminal" })
vim.keymap.set("t", "<esc>", vim.cmd.ToggleTerm, { desc = "Close terminal" })

-- Open debug console
vim.keymap.set(
  "n",
  "<leader>dd",
  "<Cmd>lua require('dapui').float_element('repl', {position='center', enter=true, width=200, height=200})<CR>",
  { desc = "Debug Console" }
)

-- Rename
vim.keymap.set("n", "<leader>rn", "<Cmd>lua vim.lsp.buf.rename()<CR>", { desc = "Rename" })

-- Launch DAP configurations
vim.keymap.set("n", "<leader>df", function()
  require("dap-python").setup()
  require("dap").continue()
end, { desc = "Launch configuration" })

-- DAP stop on exceptions
vim.keymap.set("n", "<leader>dx", function()
  require("dap").set_exception_breakpoints({ "Warning", "Error", "Exception" })
end, { desc = "Stop on exceptions" })

vim.keymap.set("n", "<leader>dX", function()
  require("dap").set_exception_breakpoints({ "Notice", "Warning", "Error", "Exception" })
end, { desc = "Stop on all" })

-- Git conflicts (plugin-free)
local function find_conflict_markers()
  local bufnr = 0
  local cursor_line = vim.api.nvim_win_get_cursor(0)[1] -- 1-indexed
  local line_count = vim.api.nvim_buf_line_count(bufnr)

  -- Search backward (inclusive of cursor line) for <<<<<<<
  local ours_start = nil
  for i = cursor_line, 1, -1 do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if line:match("^>>>>>>>") then
      break -- hit end of a previous conflict, cursor is not inside one
    end
    if line:match("^<<<<<<<") then
      ours_start = i
      break
    end
  end
  if not ours_start then
    vim.notify("Not inside a git conflict block", vim.log.levels.WARN)
    return nil
  end

  -- Search forward from ours_start for ======= then >>>>>>>
  local divider = nil
  local theirs_end = nil
  for i = ours_start + 1, line_count do
    local line = vim.api.nvim_buf_get_lines(bufnr, i - 1, i, false)[1]
    if not divider and line:match("^=======") then
      divider = i
    elseif divider and line:match("^>>>>>>>") then
      theirs_end = i
      break
    elseif line:match("^<<<<<<<") then
      break -- malformed: hit another conflict start
    end
  end

  if not divider or not theirs_end then
    vim.notify("Malformed git conflict block", vim.log.levels.WARN)
    return nil
  end
  if cursor_line > theirs_end then
    vim.notify("Not inside a git conflict block", vim.log.levels.WARN)
    return nil
  end

  return { ours_start = ours_start, divider = divider, theirs_end = theirs_end }
end

local function git_conflict_choose_ours()
  local m = find_conflict_markers()
  if not m then
    return
  end
  -- Delete bottom-up to keep line numbers stable
  vim.api.nvim_buf_set_lines(0, m.divider - 1, m.theirs_end, false, {})
  vim.api.nvim_buf_set_lines(0, m.ours_start - 1, m.ours_start, false, {})
end

local function git_conflict_choose_theirs()
  local m = find_conflict_markers()
  if not m then
    return
  end
  vim.api.nvim_buf_set_lines(0, m.theirs_end - 1, m.theirs_end, false, {})
  vim.api.nvim_buf_set_lines(0, m.ours_start - 1, m.divider, false, {})
end

local function git_conflict_choose_both()
  local m = find_conflict_markers()
  if not m then
    return
  end
  -- Delete bottom-up: >>>>>>> then ======= then <<<<<<<
  vim.api.nvim_buf_set_lines(0, m.theirs_end - 1, m.theirs_end, false, {})
  vim.api.nvim_buf_set_lines(0, m.divider - 1, m.divider, false, {})
  vim.api.nvim_buf_set_lines(0, m.ours_start - 1, m.ours_start, false, {})
end

local function git_conflict_next()
  local found = vim.fn.search("^<<<<<<<", "w")
  if found == 0 then
    vim.notify("No more git conflicts", vim.log.levels.INFO)
  end
end

local function git_conflict_prev()
  local found = vim.fn.search("^<<<<<<<", "bw")
  if found == 0 then
    vim.notify("No more git conflicts", vim.log.levels.INFO)
  end
end

vim.keymap.set("n", "<leader>go", git_conflict_choose_ours, { desc = "Git conflict choose ours" })
vim.keymap.set("n", "<leader>gt", git_conflict_choose_theirs, { desc = "Git conflict choose theirs" })
vim.keymap.set("n", "<leader>gC", git_conflict_choose_both, { desc = "Git conflict choose both" })
vim.keymap.set("n", "<leader>gn", git_conflict_next, { desc = "Git conflict next" })
vim.keymap.set("n", "<leader>gN", git_conflict_prev, { desc = "Git conflict previous" })

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

-- Project management
local project_manager = require("project_manager")
vim.keymap.set("n", "<leader>ps", project_manager.switch_project, { desc = "Switch Project (restart)" })
vim.keymap.set("n", "<leader>pf", project_manager.open_project_file, { desc = "Open File from Project" })

vim.keymap.set("n", "<leader>cD", "<Cmd>Telescope diagnostics<CR>", { desc = "Diagnostics" })

vim.keymap.set("n", "<leader>fo", "<Cmd> lua vim.lsp.buf.references()<CR>", { desc = "Find references" })

-- Remap normal marks as global
-- Use lowercase and uppercase for global marks

local low = function(i)
  return string.char(97 + i)
end
local upp = function(i)
  return string.char(65 + i)
end

for i = 0, 25 do
  vim.keymap.set("n", "m" .. low(i), "m" .. upp(i))
end
for i = 0, 25 do
  vim.keymap.set("n", "'" .. low(i), "'" .. upp(i))
end

-- Remap search and Grep
vim.keymap.set("n", "fs", function()
  Snacks.picker.grep({ cwd = vim.fn.getcwd() })
end, { desc = "Live Grep (Project Root)" })

vim.keymap.set("n", "fl", function()
  Snacks.picker.grep({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Live Grep (Buffer Directory)" })

vim.keymap.set("n", "fj", "/", { desc = "Search in buffer" })
