-- =============================================================================
-- pack.lua — Plugin loader built on top of vim.pack (Neovim ≥ 0.12)
--
-- Architecture
-- ─────────────
-- Each file inside  lua/plugin/<name>.lua  represents one logical plugin unit.
-- It is responsible for:
--   1. Declaring the plugin(s) it needs via  vim.pack.add(...)
--   2. Configuring the plugin after it becomes available.
--
-- This module auto-discovers all files inside lua/plugin/, skips any whose
-- base-name appears in  vim.g.disabled_plugins , then requires the rest.
-- Files are required in alphabetical order.  If a specific loading order is
-- needed, prefix the filename with a number (e.g. "01_treesitter.lua").
-- =============================================================================

local M = {}

--- Resolve the absolute path to the  lua/plugin/  directory.
local function plugin_dir()
  return vim.fn.stdpath('config') .. '/lua/plugin'
end

--- Build a set from the disabled-plugin list for O(1) lookup.
local function disabled_set()
  local set = {}
  for _, name in ipairs(vim.g.disabled_plugins or {}) do
    set[name] = true
  end
  return set
end

--- Return all *.lua files inside lua/plugin/ sorted alphabetically.
local function discover_plugins(dir)
  local pattern = dir .. '/*.lua'
  local files = vim.fn.glob(pattern, false, true) -- returns a list
  table.sort(files)
  return files
end

--- Load a single plugin file by its filesystem path.
-- @param path  string  absolute path to the .lua file
local function load_plugin(path)
  -- Derive the Lua module name:  lua/plugin/foo.lua  →  plugin.foo
  local name = vim.fn.fnamemodify(path, ':t:r') -- base-name without extension
  local module = 'plugin.' .. name
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify(
      string.format('[pack] failed to load plugin module "%s":\n%s', module, err),
      vim.log.levels.ERROR
    )
  end
end

--- Public entry point – call once from init.lua.
function M.setup()
  -- vim.pack is available since Neovim 0.12.  Guard against older versions.
  if not vim.pack then
    vim.notify(
      '[pack] vim.pack is not available.  Neovim 0.12+ is required.',
      vim.log.levels.ERROR
    )
    return
  end

  local dir = plugin_dir()
  local disabled = disabled_set()
  local files = discover_plugins(dir)

  for _, path in ipairs(files) do
    local name = vim.fn.fnamemodify(path, ':t:r')
    if disabled[name] then
      vim.notify(string.format('[pack] plugin "%s" is disabled – skipping', name), vim.log.levels.DEBUG)
    else
      load_plugin(path)
    end
  end
end

return M
