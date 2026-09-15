# Project Tabs Design

## Goal

Add `<leader>pt` to open a selected repository in a new native Neovim tab while preserving the existing Bufferline file-buffer display.

## Behavior

- Reuse the project discovery and Telescope selection used by `<leader>ps`.
- Create no tab when no projects exist or selection is cancelled.
- On selection, open a new native tab and set its tab-local working directory to the selected repository with `tcd`.
- Store the repository basename in a tab-local variable for display.
- Do not close or alter buffers, terminals, working directories, or layouts in existing tabs.
- Use two rows at the top of the editor: named project tabs in Neovim's native tabline and Bufferline in the global winbar directly below it.
- Show each named project tab, highlight the active tab, and allow clicking a name to switch to that tab.
- Keep Bufferline in buffer mode and reuse its renderer in the winbar so buffer names, icons, diagnostics, close buttons, pinning, groups, ordering, and click actions continue to work.
- Disable Bufferline hover effects because the plugin hardcodes hover detection to screen row 1.
- Retain the active repository name in Lualine as secondary context.

## Files

- `lua/project_manager.lua`: add the project-tab operation.
- `lua/config/keymaps/utility.lua`: map `<leader>pt`.
- `lua/project_tabs.lua`: render named native tabs in the native tabline and install the two-row layout.
- `lua/plugins/bufferline.lua`: move Bufferline's renderer to the global winbar and disable hover effects.
- `lua/plugins/lualine.lua`: add the tab-local repository name to Lualine.

## Error Handling

Use the existing warning when no repositories are found. Treat picker cancellation as a no-op. Escape selected paths before passing them to Ex commands.

## Verification

- Load the configuration headlessly to catch Lua and plugin configuration errors.
- Test that opening a project tab creates one tab, assigns a tab-local working directory and project name, and leaves the original tab's directory unchanged.
- Confirm that project tabs render in the first row, Bufferline renders in the second row, active project highlighting works, and both rows retain their click actions.
