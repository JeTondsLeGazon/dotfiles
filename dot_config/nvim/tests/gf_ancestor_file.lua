local config = vim.fn.stdpath("config")
local root = vim.fn.tempname()
local teamcity = root .. "/.teamcity"
local build_steps = teamcity .. "/settings/cloud/buildSteps"
local scripts = teamcity .. "/settings/cloud/scripts"
vim.fn.mkdir(build_steps, "p")
vim.fn.mkdir(scripts, "p")

local source = build_steps .. "/getVulnerabilityReport.kt"
local target = scripts .. "/get#vulnerability_report.sh"
vim.fn.writefile({ "script" }, target)
vim.fn.writefile({ '"settings/cloud/scripts/get#vulnerability_report.sh"' }, source)

vim.cmd.edit(vim.fn.fnameescape(source))
vim.api.nvim_win_set_cursor(0, { 1, 1 })
dofile(config .. "/lua/config/keymaps/navigation.lua")

local mapping = vim.fn.maparg("gf", "n", false, true)
assert(mapping.callback, "gf must have a Lua callback")
mapping.callback()
assert(vim.api.nvim_buf_get_name(0) == target, "gf must open a path relative to the nearest matching ancestor")

vim.fn.delete(root, "rf")
vim.cmd.quitall({ bang = true })
