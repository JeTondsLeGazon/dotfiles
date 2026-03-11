-- Git conflict resolution (plugin-free) and FZF git commands

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
