package.loaded.project_manager = { switch_project = function() end, open_project_file = function() end }

local notifications = {}
local timers = {}
local jobs = {}
local hidden = {}

Snacks = {
  notify = function(text, opts)
    table.insert(notifications, { text = text, opts = opts })
  end,
  notifier = {
    hide = function(id)
      table.insert(hidden, id)
    end,
  },
}

vim.fn.jobstart = function(command, opts)
  table.insert(jobs, { command = command, opts = opts })
  return #jobs
end

vim.defer_fn = function(fn, ms)
  table.insert(timers, { fn = fn, ms = ms })
end

dofile(vim.fn.stdpath("config") .. "/lua/config/keymaps/utility.lua")

local cases = {
  { key = "<leader>rl", command = { "uv", "lock", "--verbose" }, title = "uv lock" },
  { key = "<leader>rk", command = "ruff format . && ruff check --fix .", title = "ruff format + check" },
  { key = "<leader>ks", command = "uv sync --all-groups --all-extras && uv pip install debugpy", title = "uva" },
  { key = "<leader>kx", command = { "ruff", "check", "--fix", "--unsafe-fixes", "." }, title = "rcfu" },
}

for i, case in ipairs(cases) do
  vim.fn.maparg(case.key, "n", false, true).callback()
  assert(vim.deep_equal(jobs[i].command, case.command), case.key .. " command")
  assert(notifications[#notifications].opts.title == case.title, case.key .. " title")
  assert(notifications[#notifications].opts.timeout == 0, case.key .. " progress timeout")
  jobs[i].opts.on_stdout(i, { "progress", "" })
  assert(vim.wait(1000, function()
    return notifications[#notifications].text == "progress"
  end), case.key .. " output")
  if i == 1 then
    jobs[i].opts.on_stderr(i, { "DEBUG resolving", "DEBUG done" })
    assert(vim.wait(1000, function()
      return notifications[#notifications].text == "resolving\ndone"
    end), "uv lock debug output")
  end
  jobs[i].opts.on_exit(i, i == 1 and 1 or 0)
  assert(vim.wait(1000, function()
    return #timers == i
  end), case.key .. " finish")
  local final = notifications[#notifications]
  assert(final.opts.timeout <= 5000, case.key .. " final timeout")
  assert(final.opts.level == (i == 1 and "error" or "info"), case.key .. " status")
  local count = #notifications
  jobs[i].opts.on_stderr(i, { "late output" })
  vim.wait(50)
  assert(#notifications == count, case.key .. " late output replaced completion")
  assert(timers[i].ms == 5000, case.key .. " hide timer")
  timers[i].fn()
  assert(hidden[i] == final.opts.id, case.key .. " hide id")
end

vim.cmd.quitall({ bang = true })
