local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = config_root .. "/lua/?.lua;" .. package.path

local project_manager = require("project_manager")
local original_tab = vim.fn.tabpagenr()
local original_cwd = vim.fn.getcwd(-1, original_tab)
local temp_root = vim.fn.tempname()
local project_path = temp_root .. "/sample-repo"

vim.fn.mkdir(project_path, "p")

local ok, err = pcall(function()
  project_manager.open_project_in_tab(project_path)

  assert(#vim.api.nvim_list_tabpages() == 2, "expected a new tab")
  assert(vim.fn.getcwd() == project_path, "expected the new tab to use the project directory")
  assert(vim.t.project_name == "sample-repo", "expected the new tab to store the repository name")
  assert(vim.fn.getcwd(-1, original_tab) == original_cwd, "expected the original tab directory to remain unchanged")
end)

vim.cmd("tabonly!")
vim.fn.delete(temp_root, "rf")

if not ok then
  error(err)
end
