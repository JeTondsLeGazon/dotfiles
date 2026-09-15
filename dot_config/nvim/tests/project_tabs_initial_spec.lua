local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = config_root .. "/lua/?.lua;" .. package.path

local original_cwd = vim.fn.getcwd()
local temp_root = vim.fn.tempname()
local project_root = temp_root .. "/original-repo"
local nested_dir = project_root .. "/src/module"

vim.fn.mkdir(project_root .. "/.git", "p")
vim.fn.mkdir(nested_dir, "p")
vim.cmd.cd({ args = { nested_dir } })

local ok, err = pcall(function()
  require("project_tabs").setup()

  assert(vim.t.project_name == "original-repo", "expected setup to name the original tab from its Git root")
  assert(require("project_tabs").render():find("original%-repo"), "expected the original project in the tabline")
end)

vim.cmd.cd({ args = { original_cwd } })
vim.fn.delete(temp_root, "rf")

if not ok then
  error(err)
end
