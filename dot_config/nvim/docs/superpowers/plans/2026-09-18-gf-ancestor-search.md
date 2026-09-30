# Resolve Relative Files with `gf` Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make normal-mode `gf` open paths relative to any ancestor of the current buffer directory while leaving `gx` unchanged.

**Architecture:** Capture native `gf` as a normal-mode command before replacing it. The custom callback checks absolute paths directly and relative paths from the buffer directory upward, opens the nearest readable match with escaped `:edit`, and executes native `gf` when no match exists.

**Tech Stack:** Neovim 0.12 Lua API, LazyVim configuration, headless Neovim regression test, StyLua

## Global Constraints

- `gx` remains unchanged.
- Relative paths search the current buffer directory and each ancestor, nearest first.
- Absolute paths are checked directly.
- Only readable files are opened by the custom resolver.
- Unresolved paths execute native `gf` so its `'path'` lookup and standard errors remain available.
- Add no plugin, TeamCity-specific path, or recursive filesystem scan.
- The configuration directory is not a Git repository, so commit steps are omitted.

---

### Task 1: Ancestor-Aware `gf`

**Files:**
- Create: `tests/gf_ancestor_file.lua`
- Modify: `init.lua:2-3`
- Modify: `lua/config/keymaps/navigation.lua:1-3`

**Interfaces:**
- Consumes: `vim.fn.expand("<cfile>")`, `vim.api.nvim_buf_get_name(0)`, `vim.fs.parents()`, `vim.fn.filereadable()`, and native normal command `gf` through `vim.cmd.normal({ "gf", bang = true })`.
- Produces: normal-mode mapping `gf` with description `Open file relative to buffer ancestor`; the nearest readable candidate becomes the current buffer through `vim.cmd.edit(vim.fn.fnameescape(candidate))`.
- Startup integration: `init.lua` requires `config.keymaps` after `config.lazy` so `lua/config/keymaps/init.lua` loads the mapping.

- [ ] **Step 1: Write the failing behavior test**

Create `tests/gf_ancestor_file.lua`:

```lua
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
```

- [ ] **Step 2: Run the behavior test and verify it fails**

Run:

```bash
nvim --headless -u NONE -l tests/gf_ancestor_file.lua
```

Expected: FAIL with `gf must have a Lua callback`, because no custom `gf` mapping exists.

- [ ] **Step 3: Implement the minimal mapping**

Add near the beginning of `lua/config/keymaps/navigation.lua`:

```lua
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
```

- [ ] **Step 4: Run the focused test and verify it passes**

Run:

```bash
nvim --headless -u NONE -l tests/gf_ancestor_file.lua
```

Expected: exit code 0 with no assertion errors. The fixture proves nearest-ancestor resolution and escaping of `#` for `:edit`.

- [ ] **Step 5: Load the modular keymaps during normal startup**

Add to `init.lua` immediately after `require("config.lazy")`:

```lua
require("config.keymaps")
```

- [ ] **Step 6: Format implementation and test files**

Run:

```bash
/home/hugo/.local/share/nvim/mason/packages/stylua/stylua init.lua lua/config/keymaps/navigation.lua tests/gf_ancestor_file.lua
```

Expected: exit code 0.

- [ ] **Step 7: Re-run focused behavior test**

Run:

```bash
nvim --headless -u NONE -l tests/gf_ancestor_file.lua
```

Expected: exit code 0 with no assertion errors.

- [ ] **Step 8: Verify startup mapping and unchanged `gx`**

Run:

```bash
nvim --headless "+lua local gf=vim.fn.maparg('gf','n',false,true); local gx=vim.fn.maparg('gx','n',false,true); assert(gf.callback and gf.desc == 'Open file relative to buffer ancestor'); assert(gx.desc == 'Opens filepath or URI under cursor with the system handler (file explorer, web browser, …)')" +qa
```

Expected: exit code 0 with no startup or assertion errors.

- [ ] **Step 9: Verify formatting**

Run:

```bash
/home/hugo/.local/share/nvim/mason/packages/stylua/stylua --check init.lua lua/config/keymaps/navigation.lua tests/gf_ancestor_file.lua
```

Expected: exit code 0.
