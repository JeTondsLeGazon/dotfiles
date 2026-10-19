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

-- Add a parameter to the next Python definition, or an argument to the next call.
local function add_to_next_argument_list(kind)
  if vim.bo.filetype ~= "python" then
    vim.notify("This argument mapping currently supports Python files only", vim.log.levels.INFO)
    return
  end

  local ok, parser = pcall(vim.treesitter.get_parser, 0, "python")
  if not ok then
    vim.notify("Python Tree-sitter parser is unavailable", vim.log.levels.WARN)
    return
  end

  local list_type = kind == "definition" and "parameters" or "argument_list"
  local parent_type = kind == "definition" and "function_definition" or "call"
  local cursor = vim.api.nvim_win_get_cursor(0)
  local cursor_row, cursor_col = cursor[1] - 1, cursor[2]
  local current, next_list

  local function visit(node)
    if node:type() == list_type and node:parent() and node:parent():type() == parent_type then
      local sr, sc, er, ec = node:range()
      if (sr < cursor_row or (sr == cursor_row and sc <= cursor_col))
        and (er > cursor_row or (er == cursor_row and ec > cursor_col)) then
        -- If nested calls overlap, use the innermost list under the cursor.
        current = node
      elseif not next_list and (sr > cursor_row or (sr == cursor_row and sc > cursor_col)) then
        next_list = node
      end
    end
    for child in node:iter_children() do
      visit(child)
    end
  end

  visit(parser:parse()[1]:root())
  local list = current or next_list
  if not list then
    vim.notify("No next function " .. kind, vim.log.levels.INFO)
    return
  end

  local sr, sc, er, ec = list:range()
  local close_col = ec - 1 -- The closing parenthesis is the last character.
  local last_argument, trailing_comma
  for child in list:iter_children() do
    if child:named() and child:type() ~= "comment" then
      last_argument = child
      trailing_comma = false
    elseif child:type() == "," then
      trailing_comma = true
    end
  end

  local needs_comma = last_argument and not trailing_comma
  local multiline = sr ~= er
  if not multiline then
    local before_close = vim.api.nvim_buf_get_text(0, sr, sc + 1, er, close_col, {})[1]
    local insertion = (needs_comma and "," or "") .. (last_argument and not before_close:match("%s$") and " " or "")
    vim.api.nvim_buf_set_text(0, er, close_col, er, close_col, { insertion })
    vim.api.nvim_win_set_cursor(0, { er + 1, close_col + #insertion })
  else
    local base_indent = string.rep(" ", vim.fn.indent(sr + 1))
    local indent = base_indent .. string.rep(" ", vim.fn.shiftwidth())
    if last_argument then
      local argument_row = last_argument:start()
      if argument_row > sr then
        local line = vim.api.nvim_buf_get_lines(0, argument_row, argument_row + 1, false)[1]
        indent = line:match("^%s*")
      end
    end

    if needs_comma then
      local argument_row, argument_col = last_argument:end_()
      vim.api.nvim_buf_set_text(0, argument_row, argument_col, argument_row, argument_col, { "," })
      if argument_row == er then
        close_col = close_col + 1
      end
    end

    local closing_line = vim.api.nvim_buf_get_lines(0, er, er + 1, false)[1]
    if closing_line:sub(1, close_col):match("^%s*$") then
      vim.api.nvim_buf_set_text(0, er, 0, er, 0, { indent, "" })
      vim.api.nvim_win_set_cursor(0, { er + 1, #indent })
    else
      vim.api.nvim_buf_set_text(0, er, close_col, er, close_col, { "", indent, base_indent })
      vim.api.nvim_win_set_cursor(0, { er + 2, #indent })
    end
  end
  vim.cmd.startinsert({ bang = multiline })
end

vim.keymap.set("n", "ad", function()
  add_to_next_argument_list("definition")
end, { desc = "Add parameter to next Python function definition" })

vim.keymap.set("n", "ac", function()
  add_to_next_argument_list("call")
end, { desc = "Add argument to next Python function call" })

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
