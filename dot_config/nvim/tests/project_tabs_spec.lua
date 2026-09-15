local config_root = vim.fn.fnamemodify(debug.getinfo(1, "S").source:sub(2), ":p:h:h")
package.path = config_root .. "/lua/?.lua;" .. package.path

vim.t.project_name = "first-repo"
vim.cmd.tabnew()
vim.t.project_name = "second-repo"

local ok, project_tabs = pcall(require, "project_tabs")
assert(ok, "expected the project_tabs module to exist")

local rendered = project_tabs.render()

assert(rendered:find("first%-repo"), "expected the first project tab name")
assert(rendered:find("second%-repo"), "expected the second project tab name")
assert(rendered:find("%%1@v:lua.ProjectTabClick@"), "expected the first tab to be clickable")
assert(rendered:find("%%2@v:lua.ProjectTabClick@"), "expected the second tab to be clickable")
assert(rendered:find("%%#BufferLineTab# first%-repo"), "expected the inactive tab highlight")
assert(rendered:find("%%#BufferLineTabSelected# second%-repo"), "expected the active tab highlight")

ProjectTabClick(1)
assert(vim.fn.tabpagenr() == 1, "expected clicking a project name to switch tabs")

project_tabs.setup()
assert(vim.o.tabline == "%!v:lua.ProjectTabs()", "expected project tabs in the top tabline")
assert(vim.o.showtabline == 2, "expected the project tabline to remain visible")
assert(vim.o.winbar == "%{%v:lua.nvim_bufferline()%}", "expected Bufferline in the winbar below")

local bufferline_spec = dofile(config_root .. "/lua/plugins/bufferline.lua")
local bufferline_opts = { options = {} }
bufferline_spec.opts(nil, bufferline_opts)
assert(bufferline_opts.options.show_tab_indicators == false, "expected no duplicate tab indicators in the buffer row")
assert(bufferline_opts.options.show_close_icon == false, "expected no duplicate tab close button in the buffer row")
assert(bufferline_opts.options.show_buffer_close_icons ~= false, "expected buffer close buttons to remain enabled")

vim.cmd("tabonly!")
