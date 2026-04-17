-- =============================================================================
-- plugin/render_markdown.lua — Markdown rendering + table visualisation
--
-- render-markdown.nvim renders Markdown directly in the buffer:
--   • Pretty headings with icons
--   • Styled code fences
--   • Checkbox rendering  (- [ ] / - [x])
--   • Table alignment with borders
--   • Blockquote/callout icons
-- =============================================================================

vim.pack.add('MeanderingProgrammer/render-markdown.nvim')

local ok, rm = pcall(require, 'render-markdown')
if not ok then return end

-- Internal state: track per-buffer enabled state for lualine component
local _enabled = true

rm.setup({
  enabled = true,
  -- Only activate in markdown and related file types
  file_types = { 'markdown', 'md', 'mdx', 'quarto' },
  render_modes = { 'n', 'c' }, -- render in normal and command mode

  -- ── Headings ──────────────────────────────────────────────────────────────
  heading = {
    enabled = true,
    -- Icons for h1..h6
    icons   = { '󰲡 ', '󰲣 ', '󰲥 ', '󰲧 ', '󰲩 ', '󰲫 ' },
    -- Background highlight per level
    backgrounds = {
      'RenderMarkdownH1Bg', 'RenderMarkdownH2Bg', 'RenderMarkdownH3Bg',
      'RenderMarkdownH4Bg', 'RenderMarkdownH5Bg', 'RenderMarkdownH6Bg',
    },
  },

  -- ── Code blocks ───────────────────────────────────────────────────────────
  code = {
    enabled   = true,
    style     = 'full',   -- 'full' | 'language' | 'normal' | 'none'
    language_icon = true,
    border    = 'thin',   -- 'thin' | 'thick' | 'none'
  },

  -- ── Tables ────────────────────────────────────────────────────────────────
  pipe_table = {
    enabled = true,
    preset  = 'heavy', -- 'none' | 'round' | 'double' | 'heavy'
  },

  -- ── Checkboxes ────────────────────────────────────────────────────────────
  checkbox = {
    enabled   = true,
    unchecked = { icon = '󰄱 ', highlight = 'RenderMarkdownUnchecked' },
    checked   = { icon = '󰱒 ', highlight = 'RenderMarkdownChecked'   },
    custom    = {
      todo = { raw = '[-]', rendered = '󰥔 ', highlight = 'RenderMarkdownTodo' },
    },
  },

  -- ── Bullet lists ──────────────────────────────────────────────────────────
  bullet = {
    enabled = true,
    icons   = { '●', '○', '◆', '◇' },
  },

  -- ── Callouts / blockquotes ────────────────────────────────────────────────
  quote = { enabled = true, icon = '▋', highlight = 'RenderMarkdownQuote' },

  callout = {
    note    = { raw = '[!NOTE]',    rendered = '󰋽 Note',    highlight = 'RenderMarkdownInfo'    },
    tip     = { raw = '[!TIP]',     rendered = '󰌶 Tip',     highlight = 'RenderMarkdownSuccess' },
    important = { raw = '[!IMPORTANT]', rendered = '󰅾 Important', highlight = 'RenderMarkdownHint' },
    warning = { raw = '[!WARNING]', rendered = '󰀪 Warning', highlight = 'RenderMarkdownWarn'    },
    caution = { raw = '[!CAUTION]', rendered = '󰳦 Caution', highlight = 'RenderMarkdownError'   },
  },
})

-- ── Public helpers (used by lualine component and keymap) ───────────────────
local M = {}

function M.is_enabled()
  return _enabled
end

function M.toggle()
  if _enabled then
    rm.disable()
    _enabled = false
    vim.notify('Markdown rendering OFF', vim.log.levels.INFO)
  else
    rm.enable()
    _enabled = true
    vim.notify('Markdown rendering ON', vim.log.levels.INFO)
  end
end

-- Keymap registered here so it works without legendary being loaded
vim.keymap.set('n', '<leader>tm', M.toggle, {
  desc   = 'Toggle markdown rendering',
  silent = true,
})

return M
