-- =============================================================================
-- plugin/bullets.lua — Bullet list continuation + checkbox / checklist helpers
--
-- bullets.vim provides:
--   • Automatic continuation of bullet lists when pressing Enter
--   • Auto-increment numbered lists
--   • Checkbox toggling (<leader>x in normal mode while on a list item)
--   • Renumbering of ordered lists
-- =============================================================================

vim.pack.add('bullets-vim/bullets.vim')

-- bullets.vim is configured through global variables (it's a Vimscript plugin)
vim.g.bullets_enabled_file_types = {
  'markdown', 'text', 'gitcommit', 'scratch',
}

-- Enable all bullet types
vim.g.bullets_enable_in_empty_buffers = 0
vim.g.bullets_set_mappings            = 1   -- let plugin set default mappings
vim.g.bullets_mapping_leader          = ''  -- use default keys

-- Checkbox markers (unchecked / checked / partial)
vim.g.bullets_checkbox_markers        = ' .oOX'
-- Cycle through markers with <C-Space>
vim.g.bullets_checkbox_partials_toggle = 1

-- Auto-pad list items to align wrapped text
vim.g.bullets_auto_indent_new_line    = 1

-- Renumber on sort / delete
vim.g.bullets_delete_last_bullet_if_empty = 1
vim.g.bullets_line_spacing               = 1

-- ── Additional Markdown editing helpers ────────────────────────────────────
-- nvim-autopairs: auto-close brackets, backticks, etc.
vim.pack.add('windwp/nvim-autopairs')
local ap_ok, autopairs = pcall(require, 'nvim-autopairs')
if ap_ok then
  autopairs.setup({
    check_ts             = true,  -- use treesitter for smarter pairing
    ts_config            = { lua = { 'string', 'source' } },
    disable_filetype     = { 'TelescopePrompt', 'spectre_panel' },
    fast_wrap            = {
      map          = '<M-e>',
      chars        = { '{', '[', '(', '"', "'" },
      pattern      = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
      offset       = 0,
      end_key      = '$',
      keys         = 'qwertyuiopzxcvbnmasdfghjkl',
      check_comma  = true,
      highlight    = 'PmenuSel',
      highlight_grey = 'LineNr',
    },
  })
end
