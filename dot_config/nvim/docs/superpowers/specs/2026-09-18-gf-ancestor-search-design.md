# Resolve Relative Files with `gf`

## Problem

Native `gf` cannot resolve paths that are relative to an ancestor of the current buffer directory. In Vision Builder's TeamCity configuration, `getVulnerabilityReport.kt` contains `settings/cloud/scripts/get_vulnerability_report.sh`, which is relative to `.teamcity`, not to the Kotlin file's `buildSteps` directory.

## Behavior

- `gx` remains unchanged.
- Normal-mode `gf` extracts the path under the cursor with `<cfile>`.
- Absolute paths are checked directly.
- Relative paths are appended to the current buffer directory and then to each ancestor directory, nearest first.
- The first readable file is opened in the current window with `:edit`.
- The selected path is escaped before it is passed to `:edit`.
- If no readable file is found, native `gf` runs so its standard `'path'` lookup and error behavior remain available.

## Implementation

Add the mapping to `lua/config/keymaps/navigation.lua`. Capture native `gf` before replacing it, then resolve relative paths by walking from the current buffer directory to the filesystem root with `vim.fs.parents`.

Require `config.keymaps` from `init.lua` after LazyVim setup because the existing modular keymap index is located at `lua/config/keymaps/init.lua` and is not loaded automatically as LazyVim's conventional `lua/config/keymaps.lua` file.

No plugin, TeamCity-specific path, or recursive filesystem scan is needed.

## Verification

Use a headless Neovim test with a temporary directory structure equivalent to:

```text
.teamcity/
  settings/cloud/buildSteps/getVulnerabilityReport.kt
  settings/cloud/scripts/get_vulnerability_report.sh
```

The test places the cursor on `settings/cloud/scripts/get_vulnerability_report.sh`, invokes the installed `gf` callback, and verifies that the shell script becomes the current buffer. It also uses a filename requiring command escaping. Finally, start the full Neovim configuration headlessly and assert that the custom `gf` mapping is installed while `gx` retains its built-in description.
