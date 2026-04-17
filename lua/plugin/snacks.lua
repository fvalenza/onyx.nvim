-- =============================================================================
-- plugin/snacks.lua — Snacks.nvim  (picker, notifier, dashboard, …)
--
-- Snacks is a collection of small but powerful utilities from folke.
-- We use it primarily for:
--   • Snacks.picker  — file / grep / heading search
--   • Snacks.notifier — nice UI notifications replacing vim.notify
--   • Snacks.bigfile  — disable heavy features for large files
-- =============================================================================

vim.pack.add('folke/snacks.nvim')

local ok, snacks = pcall(require, 'snacks')
if not ok then return end

snacks.setup({
  -- ── Picker ───────────────────────────────────────────────────────────────
  picker = {
    enabled = true,
    -- Use a centered layout
    layout = {
      preset = 'default',
    },
  },

  -- ── Notifier ─────────────────────────────────────────────────────────────
  notifier = {
    enabled = true,
    timeout = 3000,
    style    = 'fancy',
  },

  -- ── Big-file guard ────────────────────────────────────────────────────────
  bigfile = {
    enabled   = true,
    size      = 1.5 * 1024 * 1024, -- 1.5 MB
  },

  -- ── Dashboard ─────────────────────────────────────────────────────────────
  dashboard = {
    enabled = true,
    sections = {
      { section = 'header' },
      { icon = ' ', title = 'Recent Files',  section = 'recent_files', indent = 2, padding = 1 },
      { icon = ' ', title = 'Keymaps',       section = 'keys',         indent = 2, padding = 1 },
      { section = 'startup' },
    },
  },

  -- ── Indent guides ─────────────────────────────────────────────────────────
  indent = { enabled = true },

  -- ── Words highlight ───────────────────────────────────────────────────────
  words = { enabled = true },

  -- ── Scope ─────────────────────────────────────────────────────────────────
  scope = { enabled = true },
})

-- Override vim.notify to use Snacks notifier
vim.notify = snacks.notify

-- ── Module-level helpers ────────────────────────────────────────────────────
local M = {}

-- Picker: all headings across markdown files in the vault
-- Uses grep picker with a regex matching Markdown headings (#, ##, …)
function M.pick_headings()
  local cfg = require('config.notes')

  snacks.picker.grep({
    cwd      = cfg.vault_path,
    pattern  = '^#{1,6} ',     -- matches markdown headings
    live     = false,
    prompt   = 'Vault headings › ',
    -- Transform the result line so the filename and heading are shown nicely
    transform = function(item)
      if item.text then
        -- Strip leading spaces/tabs
        item.text = item.text:gsub('^%s+', '')
      end
      return item
    end,
    -- On confirm: open the file and jump to the heading line
    confirm = function(picker, item)
      picker:close()
      if item and item.file then
        vim.cmd('edit ' .. vim.fn.fnameescape(item.file))
        if item.pos then
          vim.api.nvim_win_set_cursor(0, { item.pos[1], 0 })
        end
      end
    end,
  })
end

-- Picker: files restricted to the vault directory
function M.pick_vault_files()
  local cfg = require('config.notes')
  snacks.picker.files({ cwd = cfg.vault_path })
end

return M
