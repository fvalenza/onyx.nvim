-- =============================================================================
-- plugin/legendary.lua — Command palette + keymap helper
--
-- legendary.nvim provides:
--   • A searchable command palette  (<leader><leader>)
--   • Auto-discovery of keymaps defined via its API
--   • Integration with vim.ui.select for a uniform picker UX
-- =============================================================================

vim.pack.add('mrjones2014/legendary.nvim')

local ok, legendary = pcall(require, 'legendary')
if not ok then return end

legendary.setup({
  -- Use Snacks.picker as the underlying picker (configured in snacks.lua).
  -- Fall back to built-in if Snacks is not available.
  extensions = {
    lazy_nvim = false,
    which_key = false,
    -- snacks integration via the default vim.ui.select override
  },

  -- Include default vim keymaps in the palette
  include_builtin        = true,
  include_legendary_cmds = true,

  -- Sort MRU items to the top
  sort = {
    most_recent_first = true,
    user_items_first  = true,
  },

  -- Keymaps registered with legendary (all plugin keymaps call legendary.keymap)
  keymaps = {
    -- ── General ──────────────────────────────────────────────────────────
    { '<leader><leader>', ':Legendary<cr>',  description = 'Command palette', mode = 'n' },

    -- ── Notes ─────────────────────────────────────────────────────────────
    {
      '<leader>nn',
      function() require('plugin.notes').create_note() end,
      description = 'Notes: create new note',
      mode = 'n',
    },
    {
      '<leader>nd',
      function() require('plugin.notes').create_daily() end,
      description = 'Notes: create daily note',
      mode = 'n',
    },
    {
      '<leader>nm',
      function() require('plugin.notes').create_moc() end,
      description = 'Notes: create Map of Content (MOC)',
      mode = 'n',
    },

    -- ── Snacks picker ─────────────────────────────────────────────────────
    { '<leader>ff', function() require('snacks').picker.files() end,            description = 'Find files',                mode = 'n' },
    { '<leader>fg', function() require('snacks').picker.grep() end,             description = 'Grep in vault',             mode = 'n' },
    { '<leader>fh', function() require('plugin.snacks').pick_headings() end,    description = 'Find headings across vault', mode = 'n' },
    { '<leader>fb', function() require('snacks').picker.buffers() end,          description = 'Find open buffers',         mode = 'n' },
    { '<leader>fr', function() require('snacks').picker.recent() end,           description = 'Recent files',              mode = 'n' },

    -- ── Outline ───────────────────────────────────────────────────────────
    { '<leader>o', '<cmd>Outline<cr>', description = 'Toggle outline panel', mode = 'n' },

    -- ── Screenshot paste ──────────────────────────────────────────────────
    { '<leader>pi', '<cmd>PasteImage<cr>', description = 'Paste screenshot into note', mode = 'n' },

    -- ── Markdown rendering ────────────────────────────────────────────────
    { '<leader>tm', function() require('plugin.render_markdown').toggle() end, description = 'Toggle markdown rendering', mode = 'n' },

    -- ── Code block execution ──────────────────────────────────────────────
    { '<leader>xe', function() require('plugin.codeblock').execute_block() end,  description = 'Execute code block under cursor', mode = 'n' },
    { '<leader>xt', function() require('plugin.codeblock').toggle_result() end,  description = 'Toggle code block / result view', mode = 'n' },
    { '<leader>xc', function() require('plugin.codeblock').clear_result() end,   description = 'Clear code block result',         mode = 'n' },

    -- ── Expression evaluator ──────────────────────────────────────────────
    { '<leader>ev', function() require('plugin.eval').eval_selection() end, description = 'Evaluate Lua expression (selection)', mode = 'v' },
    { '<leader>eE', function() require('plugin.eval').eval_line() end,      description = 'Evaluate Lua expression (line)',      mode = 'n' },
  },

  commands = {
    {
      ':NotesDaily',
      function() require('plugin.notes').create_daily() end,
      description = 'Create or open today\'s daily note',
    },
    {
      ':NotesMOC',
      function() require('plugin.notes').create_moc() end,
      description = 'Create a new Map of Content note',
    },
    {
      ':NotesNew',
      function() require('plugin.notes').create_note() end,
      description = 'Create a new note',
    },
  },
})

-- Register the palette keymap directly so it works even before legendary
-- processes its own keymap list
vim.keymap.set('n', '<leader><leader>', '<cmd>Legendary<cr>', {
  desc   = 'Command palette (legendary)',
  silent = true,
})
