-- =============================================================================
-- onyx.nvim — init.lua
-- Main entry point.  Loads core config then auto-discovers lua/plugin/ files.
-- =============================================================================

-- Leader must be set BEFORE any plugin / keymap is loaded.
vim.g.mapleader = ' '
vim.g.maplocalleader = ' '

-- ---------------------------------------------------------------------------
-- Disabled plugins
-- Add the *file-name* (without .lua extension) of any plugin file inside
-- lua/plugin/ that you want to skip entirely.  Example:
--   vim.g.disabled_plugins = { 'image', 'codeblock' }
-- ---------------------------------------------------------------------------
vim.g.disabled_plugins = {}

-- ---------------------------------------------------------------------------
-- Core configuration (order matters)
-- ---------------------------------------------------------------------------
require('config.options')
require('config.autocmds')
require('config.keymaps')

-- ---------------------------------------------------------------------------
-- Plugin loader  (vim.pack + auto-discovery of lua/plugin/ files)
-- ---------------------------------------------------------------------------
require('pack').setup()
