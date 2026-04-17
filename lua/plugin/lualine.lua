-- =============================================================================
-- plugin/lualine.lua — Statusline with custom note-workflow components
--
-- Custom components
-- ─────────────────
-- 1.  render_markdown_status — shows  󰑊 MD  when render-markdown is active,
--     dimmed otherwise.
-- 2.  codeblock_status       — shows  󰐊 EXEC  when any code block in the
--     current buffer has its output displayed via virtual text.
-- =============================================================================

vim.pack.add('nvim-lualine/lualine.nvim')
-- Optional: devicons for file-type icons in lualine
vim.pack.add('nvim-tree/nvim-web-devicons')

local ok, lualine = pcall(require, 'lualine')
if not ok then return end

-- ── Custom components ───────────────────────────────────────────────────────

local function render_markdown_status()
  local rm_ok, rm = pcall(require, 'plugin.render_markdown')
  if not rm_ok then return '' end
  if rm.is_enabled() then
    return '󰑊 MD'
  else
    return '󰑊'   -- dimmed / no label means it's off
  end
end

local function codeblock_status()
  local cb_ok, cb = pcall(require, 'plugin.codeblock')
  if not cb_ok then return '' end
  if cb.result_mode_active() then
    return '󰐊 EXEC'
  end
  return ''
end

-- Filename: show relative path from vault root when inside the vault
local function smart_filename()
  local cfg_ok, cfg = pcall(require, 'config.notes')
  local full = vim.fn.expand('%:p')
  if cfg_ok and cfg.vault_path ~= '' and full:find(cfg.vault_path, 1, true) then
    return vim.fn.fnamemodify(full, ':~:.')
  end
  return vim.fn.expand('%:t')
end

-- ── Theme ────────────────────────────────────────────────────────────────────
-- Use a dark theme by default; override here if you prefer another.
local theme = 'auto'   -- 'auto' picks a theme that matches the current colorscheme

-- ── Setup ────────────────────────────────────────────────────────────────────
lualine.setup({
  options = {
    icons_enabled        = true,
    theme                = theme,
    component_separators = { left = '', right = '' },
    section_separators   = { left = '', right = '' },
    disabled_filetypes   = {
      statusline = { 'dashboard', 'alpha', 'starter' },
      winbar     = {},
    },
    globalstatus         = true,
  },

  sections = {
    lualine_a = { 'mode' },
    lualine_b = {
      'branch',
      { 'diff', symbols = { added = ' ', modified = ' ', removed = ' ' } },
      { 'diagnostics', sources = { 'nvim_diagnostic' } },
    },
    lualine_c = {
      { smart_filename, icon = '󰈙' },
    },
    lualine_x = {
      { render_markdown_status, color = { fg = '#7aa2f7' } },
      { codeblock_status,       color = { fg = '#e0af68' } },
      'encoding',
      'fileformat',
      'filetype',
    },
    lualine_y = { 'progress' },
    lualine_z = { 'location' },
  },

  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = { 'filename' },
    lualine_x = { 'location' },
    lualine_y = {},
    lualine_z = {},
  },

  tabline = {},

  winbar = {},

  extensions = { 'outline', 'quickfix', 'man' },
})
