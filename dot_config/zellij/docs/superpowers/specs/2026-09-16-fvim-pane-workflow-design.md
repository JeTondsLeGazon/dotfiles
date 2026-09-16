# Fvim Pane Workflow Design

## Goal

Use Zellij panes as isolated project workspaces while making pane creation and fullscreen-safe pane switching available from pane mode.

## Keybindings

- `Alt p`, then `v`: create a new pane in the current tab, run `zsh -ic fvim` in it, and make that pane fullscreen.
- `Alt p`, then `p`: open a centered temporary floating pane containing the pane picker.
- Both bindings return Zellij to normal mode immediately after launching their command pane.

## Fvim Pane

The new pane runs a helper that reads its own `$ZELLIJ_PANE_ID`, unconditionally targets that pane with `zellij action toggle-fullscreen --pane-id`, and then replaces itself with the existing autoloaded `fvim` Zsh function. `fvim` selects a repository under `~/checkout`, applies the existing Python environment behavior, and starts Neovim. Targeting the helper pane's own ID avoids asynchronous focus and placement races.

## Pane Picker

A standalone executable script under `~/.local/bin` will:

1. Require execution inside Zellij and verify `zellij`, `jq`, and `fzf` are available.
2. Read pane metadata from `zellij action list-panes --json`.
3. Determine the current tab from the picker pane's `$ZELLIJ_PANE_ID`.
4. List selectable, non-plugin, non-exited terminal panes from that tab only.
5. Exclude the temporary picker pane itself.
6. Display each candidate as `title | command | cwd`, while retaining its pane ID as hidden selection data.
7. Call `zellij action focus-pane-id <id>` for the selected pane.

`focus-pane-id` is used directly because Zellij swaps the selected pane into place when the focused pane is fullscreen. The script exits without changing focus when the picker is cancelled or no candidate panes exist. The floating pane uses `close_on_exit true`, so it closes in all completion paths.

## Picker Presentation

The pane picker opens centered as a floating pane sized to 80% width and 60% height. It has a descriptive pane name and an `fzf` prompt identifying that it lists panes in the current tab.

## Files

- `~/.config/zellij/config.kdl`: add the two pane-mode bindings.
- `~/.config/zellij/bin/zellij-fvim-pane`: create and fullscreen the new `fvim` pane.
- `~/.config/zellij/bin/zellij-pane-picker`: implement pane discovery, display, selection, and focus.
- `~/.config/zellij/tests/zellij-pane-picker-test.sh`: exercise JSON filtering and selection with controlled command substitutes.

## Error Handling

- Outside Zellij: print a concise error and exit non-zero.
- Missing dependencies: print which command is missing and exit non-zero.
- Invalid or unavailable pane metadata: print a concise error and exit non-zero.
- No other pane in the current tab: display a short message for one second, then exit successfully.
- Picker cancellation: exit successfully without changing focus.

## Verification

- Run the picker test with fixture JSON covering multiple tabs, plugins, exited panes, and the picker pane itself.
- Validate `config.kdl` with `zellij setup --check`.
- Verify the KDL bindings invoke the intended commands and return to normal mode.
- In an active Zellij session, confirm pane creation runs `fvim` and pane selection works from both normal and fullscreen layouts.
