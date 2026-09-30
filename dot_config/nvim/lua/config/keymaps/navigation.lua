-- Navigation keymaps: Python class/function jumping, search/grep, marks

vim.keymap.set("n", "gf", function()
  local target = vim.fn.expand("<cfile>")
  local candidates = {}

  if vim.startswith(target, "/") then
    candidates = { vim.fs.normalize(target) }
  else
    local buffer_dir = vim.fn.fnamemodify(vim.api.nvim_buf_get_name(0), ":h")
    candidates = { vim.fs.joinpath(buffer_dir, target) }
    for parent in vim.fs.parents(buffer_dir) do
      candidates[#candidates + 1] = vim.fs.joinpath(parent, target)
    end
  end

  for _, candidate in ipairs(candidates) do
    candidate = vim.fs.normalize(candidate)
    if vim.fn.filereadable(candidate) == 1 then
      vim.cmd.edit(vim.fn.fnameescape(candidate))
      return
    end
  end

  vim.cmd.normal({ "gf", bang = true })
end, { desc = "Open file relative to buffer ancestor" })

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

-- Search and Grep (Snacks picker)
vim.keymap.set(
  "n",
  "fs",
  ":lua require('telescope').extensions.live_grep_args.live_grep_args()<CR>",
  { desc = "Live Grep (Project Root)" }
)

vim.keymap.set("n", "fl", function()
  Snacks.picker.grep({ cwd = vim.fn.expand("%:p:h") })
end, { desc = "Live Grep (Buffer Directory)" })

vim.keymap.set("n", "fj", "/", { desc = "Search in buffer" })

-- Remap normal marks as global (lowercase -> uppercase)
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

-- Remap \ to go to end of line (like $)
vim.keymap.set({ "n", "v" }, "\\", "$", { desc = "Go to end of line" })

-- Remap = to go to first non-blank character of line (like ^)
vim.keymap.set({ "n", "v" }, "=", "^", { desc = "Go to beginning of line" })

-- Window resize with larger steps (5 columns)
vim.keymap.set("n", "<C-w>>", "5<C-w>>", { desc = "Increase window width" })
vim.keymap.set("n", "<C-w><", "5<C-w><", { desc = "Decrease window width" })
