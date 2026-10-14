-- Keymaps index: loads all keymap modules
-- Each module is self-contained and registers its own keymaps on require().

require("config.keymaps.git")
require("config.keymaps.dap")
require("config.keymaps.navigation")
require("config.keymaps.lsp")
require("config.keymaps.utility")
