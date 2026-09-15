# Project Tabs Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add `<leader>pt` to open a selected repository in an independently scoped Neovim tab and visibly list project tabs without replacing Bufferline's buffer names.

**Architecture:** Extract creation of a project tab into a small exported function that can be tested without driving Telescope, then call it from a new picker action. Store the selected repository basename in `vim.t.project_name`; focused Bufferline and Lualine overrides render project navigation and active-project context.

**Tech Stack:** Lua, Neovim API, Telescope, LazyVim, Lualine

## Global Constraints

- Preserve Bufferline's existing file-buffer mode.
- Use a tab-local working directory so existing tabs retain their project context.
- Do not close existing buffers or terminals.
- The config directory is not a Git repository, so commit steps are omitted.

---

### Task 1: Project Tab Creation

**Files:**
- Create: `tests/project_manager_spec.lua`
- Modify: `lua/project_manager.lua`

**Interfaces:**
- Produces: `project_manager.open_project_in_tab(project_path: string): nil`
- Produces: `project_manager.open_project_tab(): nil`

- [ ] **Step 1: Write a failing headless test**

Create a Lua test that loads `project_manager`, calls `open_project_in_tab()` with a temporary repository path, and asserts that the tab count increases, the current tab's cwd equals the path, `vim.t.project_name` equals its basename, and the original tab's cwd is unchanged.

- [ ] **Step 2: Run the test to verify it fails**

Run: `nvim --headless -u NONE -l tests/project_manager_spec.lua`
Expected: failure because `open_project_in_tab` does not exist.

- [ ] **Step 3: Implement the minimal project-tab operation**

Add `open_project_in_tab(project_path)` using `vim.cmd.tabnew()`, `vim.cmd.tcd({ args = { project_path } })`, and `vim.t.project_name = vim.fs.basename(project_path)`. Add `open_project_tab()` using the existing project list and Telescope picker; its selection callback closes the picker, guards a missing selection, and calls `open_project_in_tab(selection.value)`.

- [ ] **Step 4: Run the test to verify it passes**

Run: `nvim --headless -u NONE -l tests/project_manager_spec.lua`
Expected: exit code 0.

### Task 2: Keymap And Statusline

**Files:**
- Modify: `lua/config/keymaps/utility.lua`
- Create: `lua/plugins/lualine.lua`

**Interfaces:**
- Consumes: `project_manager.open_project_tab(): nil`
- Consumes: `vim.t.project_name: string?`

- [ ] **Step 1: Add `<leader>pt`**

Map normal-mode `<leader>pt` to `project_manager.open_project_tab` with description `Open Project in New Tab`.

- [ ] **Step 2: Add the Lualine project component**

Create a Lazy plugin override for `nvim-lualine/lualine.nvim`. Insert a component at the start of `lualine_b` that returns `vim.t.project_name or ""` and is visible only when the tab-local name is non-empty.

- [ ] **Step 3: Verify the complete configuration**

Run: `nvim --headless "+Lazy! sync" +qa`
Expected: exit code 0 without Lua errors.

Run: `nvim --headless "+lua assert(vim.fn.maparg('<leader>pt', 'n') ~= '')" +qa`
Expected: exit code 0.

- [ ] **Step 4: Format changed Lua files**

Run: `stylua lua/project_manager.lua lua/config/keymaps/utility.lua lua/plugins/lualine.lua tests/project_manager_spec.lua`
Expected: exit code 0.

- [ ] **Step 5: Re-run all verification**

Run: `nvim --headless -u NONE -l tests/project_manager_spec.lua`
Expected: exit code 0.

Run: `nvim --headless +qa`
Expected: exit code 0 without startup errors.

### Task 3: Visible Project Tab Navigation

**Files:**
- Create: `lua/project_tabs.lua`
- Create: `lua/plugins/bufferline.lua`
- Create: `tests/project_tabs_spec.lua`

**Interfaces:**
- Produces: `project_tabs.render(): string`
- Produces: global click handler `ProjectTabClick(tabnr: number): nil`

- [ ] **Step 1: Write a failing renderer test**

Create two named native tabs, render the project-tab area, and assert that both names, tab click targets, and active/inactive highlights are present.

- [ ] **Step 2: Run the test to verify it fails**

Run: `nvim --headless -u NONE -l tests/project_tabs_spec.lua`
Expected: failure because `project_tabs` does not exist.

- [ ] **Step 3: Implement the renderer and Bufferline override**

Render named tabs as statusline segments using Bufferline's selected and unselected tab highlights. Add each segment to a `%@v:lua.ProjectTabClick@...%X` click region and expose it through Bufferline's `custom_areas.right` option without changing `options.mode`.

- [ ] **Step 4: Verify renderer and merged Bufferline options**

Run the renderer test and inspect Lazy's merged Bufferline options headlessly. Both must exit with code 0.

### Task 4: Separate Project And Buffer Rows

**Files:**
- Modify: `lua/project_tabs.lua`
- Modify: `lua/plugins/bufferline.lua`
- Modify: `tests/project_tabs_spec.lua`

**Interfaces:**
- Produces: `project_tabs.setup(): nil`
- Produces: global tabline renderer `ProjectTabs(): string`
- Reuses: global Bufferline renderer `nvim_bufferline(): string`

- [ ] **Step 1: Write a failing two-row layout test**

Extend `tests/project_tabs_spec.lua` to call `project_tabs.setup()` and assert `vim.o.tabline == "%!v:lua.ProjectTabs()"`, `vim.o.showtabline == 2`, and `vim.o.winbar == "%{%v:lua.nvim_bufferline()%}"`.

- [ ] **Step 2: Run the test to verify it fails**

Run: `nvim --headless -u NONE -l tests/project_tabs_spec.lua`
Expected: failure because `project_tabs.setup` does not exist.

- [ ] **Step 3: Install the two-row layout after Bufferline setup**

Add `project_tabs.setup()` to expose `ProjectTabs`, assign the native tabline and global winbar expressions, and force the tabline visible. Replace Bufferline's right custom area with an `opts` override that enables the buffer row, disables hover, and a `config` function that performs standard Bufferline setup before installing the two-row layout.

- [ ] **Step 4: Run focused and integration verification**

Run: `nvim --headless -u NONE -l tests/project_tabs_spec.lua`
Expected: exit code 0.

Run full headless checks for project tab creation, Bufferline's merged options, both row assignments, project rendering, keymap registration, Lualine context, and clean startup.
Expected: all commands exit with code 0.
