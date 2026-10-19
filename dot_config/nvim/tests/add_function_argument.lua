dofile(vim.fn.stdpath("config") .. "/lua/config/keymaps/navigation.lua")

local cases = {
  {
    name = "single-line call",
    key = "ac",
    input = { "other()", "foo(x)" },
    cursor = { 1, 0 },
    expected = { "other()", "foo(x)" },
    position = { 1, 6 },
  },
  {
    name = "next call",
    key = "ac",
    input = { "other() # done", "foo(x)" },
    cursor = { 1, 10 },
    expected = { "other() # done", "foo(x, )" },
    position = { 2, 7 },
  },
  {
    name = "single-line definition",
    key = "ad",
    input = { "def foo(x):", "    pass" },
    cursor = { 1, 0 },
    expected = { "def foo(x, ):", "    pass" },
    position = { 1, 11 },
  },
  {
    name = "empty definition",
    key = "ad",
    input = { "def foo():", "    pass" },
    cursor = { 1, 0 },
    expected = { "def foo():", "    pass" },
    position = { 1, 8 },
  },
  {
    name = "multiline call with comma",
    key = "ac",
    input = { "foo(", "    x,", ")" },
    cursor = { 1, 0 },
    expected = { "foo(", "    x,", "    ", ")" },
    position = { 3, 4 },
  },
  {
    name = "multiline call without comma",
    key = "ac",
    input = { "foo(", "    x", ")" },
    cursor = { 1, 0 },
    expected = { "foo(", "    x,", "    ", ")" },
    position = { 3, 4 },
  },
  {
    name = "multiline call with comment",
    key = "ac",
    input = { "foo(", "    x # comment", ")" },
    cursor = { 1, 0 },
    expected = { "foo(", "    x, # comment", "    ", ")" },
    position = { 3, 4 },
  },
  {
    name = "closing parenthesis on argument line",
    key = "ac",
    input = { "foo(", "    x)" },
    cursor = { 1, 0 },
    expected = { "foo(", "    x,", "    ", ")" },
    position = { 3, 4 },
  },
  {
    name = "multiline definition",
    key = "ad",
    input = { "def foo(", "    x", "):", "    pass" },
    cursor = { 1, 0 },
    expected = { "def foo(", "    x,", "    ", "):", "    pass" },
    position = { 3, 4 },
  },
}

for _, case in ipairs(cases) do
  local buffer = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_set_current_buf(buffer)
  vim.bo.filetype = "python"
  vim.api.nvim_buf_set_lines(buffer, 0, -1, false, case.input)
  vim.api.nvim_win_set_cursor(0, case.cursor)
  vim.fn.maparg(case.key, "n", false, true).callback()
  local actual = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
  assert(vim.deep_equal(actual, case.expected), case.name .. ": " .. vim.inspect(actual))
  assert(
    vim.deep_equal(vim.api.nvim_win_get_cursor(0), case.position),
    case.name .. " cursor: " .. vim.inspect(vim.api.nvim_win_get_cursor(0))
  )
  vim.cmd.stopinsert()
end

vim.cmd.quitall({ bang = true })
