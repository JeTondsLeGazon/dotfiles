# Fvim Pane Workflow Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add pane-mode Zellij bindings to launch an `fvim` project pane and select a terminal pane in the current tab by title, command, and cwd.

**Architecture:** A standalone Bash picker obtains pane metadata from Zellij, filters it with `jq`, delegates interactive choice to `fzf`, and focuses the selected pane by stable pane ID. KDL keybindings launch the existing `fvim` function in a normal tiled pane and the picker in a temporary floating pane.

**Tech Stack:** Zellij 0.43.1, Bash, jq 1.7, fzf, Zsh

## Global Constraints

- List selectable terminal panes in the active Zellij tab only.
- Exclude plugin, exited, and picker panes.
- Display pane title, command, and cwd.
- Switching must work while a pane is fullscreen by using `zellij action focus-pane-id`.
- Do not modify the Neovim configuration.
- The Zellij config directory is not a Git repository, so commit steps are omitted.

---

### Task 1: Pane Picker

**Files:**
- Create: `/home/hugo/.config/zellij/bin/zellij-pane-picker`
- Create: `/home/hugo/.config/zellij/tests/zellij-pane-picker-test.sh`

**Interfaces:**
- Consumes: `ZELLIJ`, `ZELLIJ_PANE_ID`, `zellij action list-panes --json`, `fzf`
- Test seam: `ZELLIJ_PANES_JSON` supplies fixture JSON instead of invoking `list-panes`
- Produces: `zellij action focus-pane-id terminal_<id>` after selection

- [ ] **Step 1: Write failing behavior tests**

Create controlled `zellij` and `fzf` executables on a temporary `PATH`. Cover filtering to the picker pane's tab, excluding plugins/exited/self panes, display of title/command/cwd, focusing the selected terminal pane, cancellation as a successful no-op, and failure outside Zellij.

- [ ] **Step 2: Run tests and verify they fail**

Run: `bash tests/zellij-pane-picker-test.sh`
Expected: failure because `/home/hugo/.config/zellij/bin/zellij-pane-picker` does not exist.

- [ ] **Step 3: Implement the picker**

Write a Bash script using strict mode. Validate environment and dependencies, load JSON from `ZELLIJ_PANES_JSON` or Zellij, derive the active tab ID from the pane matching `$ZELLIJ_PANE_ID`, generate tab-separated ID and display fields with `jq`, select through `fzf --with-nth=2..`, and focus `terminal_<id>` when selected.

- [ ] **Step 4: Run tests and verify they pass**

Run: `bash tests/zellij-pane-picker-test.sh`
Expected: all assertions pass with exit code 0.

### Task 2: Zellij Pane-Mode Bindings

**Files:**
- Modify: `/home/hugo/.config/zellij/config.kdl:9-30`

**Interfaces:**
- `Alt p`, `v` invokes `zsh -ic fvim` in a normal tiled pane.
- `Alt p`, `p` invokes `/home/hugo/.config/zellij/bin/zellij-pane-picker` in an 80% by 60% floating pane with `close_on_exit true`.

- [ ] **Step 1: Add the pane-mode bindings**

Add `Run "zsh" "-ic" "fvim"` for `v` and `Run "/home/hugo/.config/zellij/bin/zellij-pane-picker"` for `p`. Name both panes and switch back to normal mode after launching.

- [ ] **Step 2: Validate the Zellij configuration**

Run: `zellij setup --check`
Expected: `CONFIG FILE: Well defined.` and exit code 0.

- [ ] **Step 3: Verify binding definitions and picker tests**

Run: `bash tests/zellij-pane-picker-test.sh`
Expected: exit code 0.

Inspect the parsed config source to confirm pane mode contains both `Run` actions, picker dimensions, `close_on_exit true`, and `SwitchToMode "normal"`.

### Task 3: Always-Fullscreen Fvim Pane

**Files:**
- Create: `/home/hugo/.config/zellij/bin/zellij-fvim-pane`
- Create: `/home/hugo/.config/zellij/tests/zellij-fvim-pane-test.sh`
- Modify: `/home/hugo/.config/zellij/config.kdl:37-42`

**Interfaces:**
- Consumes: `$ZELLIJ_PANE_ID` assigned to the new KDL `Run` pane
- Produces: `zellij action toggle-fullscreen --pane-id terminal_<id>`
- Replaces itself with: `zsh -ic fvim`

- [ ] **Step 1: Write a failing command-sequence test**

Use controlled `zellij` and `zsh` executables with `ZELLIJ_PANE_ID=42`. Assert that the helper unconditionally toggles fullscreen on exactly `terminal_42` and invokes `zsh -ic fvim`. Also assert it fails outside Zellij.

- [ ] **Step 2: Run the test to verify it fails**

Run: `bash tests/zellij-fvim-pane-test.sh`
Expected: failure because `/home/hugo/.config/zellij/bin/zellij-fvim-pane` does not exist.

- [ ] **Step 3: Implement the helper and change the binding**

Create a strict Bash helper that validates Zellij and its numeric pane ID, targets its own pane with `toggle-fullscreen`, and replaces itself with `zsh -ic fvim`. Change pane-mode `v` to run the helper as the normal tiled pane named `fvim`.

- [ ] **Step 4: Verify behavior and configuration**

Run both helper suites, Bash syntax checks, and `zellij setup --check`.
Expected: all commands exit with code 0.
