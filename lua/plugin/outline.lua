-- =============================================================================
-- plugin/outline.lua — File outline panel
--
-- outline.nvim shows the symbol tree of the current file (headings for
-- markdown, functions/classes for code).  Navigate the outline and pressing
-- Enter jumps to that symbol in the buffer.
-- =============================================================================

vim.pack.add('hedyhli/outline.nvim')

local ok, outline = pcall(require, 'outline')
if not ok then return end

outline.setup({
  outline_window = {
    position       = 'right',
    split_command  = nil,
    width          = 28,
    relative_width = true,
    auto_close     = false,
    auto_jump      = false,
    show_numbers   = false,
    wrap           = false,
  },

  outline_items = {
    show_symbol_details   = true,
    show_symbol_lineno    = false,
    highlight_hovered_item = true,
    auto_set_cursor       = true,
  },

  -- Markdown headings are exposed via the markdown symbol provider
  providers = {
    priority = { 'lsp', 'markdown', 'norg' },
    markdown = {
      -- Show all heading levels (1–6)
      handle_groups = true,
    },
  },

  symbols = {
    -- icons for various symbol kinds
    icons = {
      File          = { icon = '󰈙', hl = 'Identifier' },
      Module        = { icon = '󰆧', hl = 'Include'    },
      Namespace     = { icon = '󰌗', hl = 'Include'    },
      Package       = { icon = '󰏖', hl = 'Include'    },
      Class         = { icon = '󰌗', hl = 'Include'    },
      Method        = { icon = 'ƒ',  hl = 'Function'  },
      Property      = { icon = '', hl = 'Identifier' },
      Field         = { icon = '󰜢', hl = 'Identifier' },
      Constructor   = { icon = '', hl = 'Special'    },
      Enum          = { icon = '󰕘', hl = 'Identifier' },
      Interface     = { icon = '󰕘', hl = 'Type'       },
      Function      = { icon = '󰊕', hl = 'Function'   },
      Variable      = { icon = '󰀫', hl = 'Identifier' },
      Constant      = { icon = '󰏿', hl = 'Constant'   },
      String        = { icon = '󰀬', hl = 'String'     },
      Number        = { icon = '󰎠', hl = 'Number'     },
      Boolean       = { icon = '', hl = 'Boolean'    },
      Array         = { icon = '󰅪', hl = 'Constant'   },
      Object        = { icon = '󰅩', hl = 'Type'       },
      Key           = { icon = '󰌋', hl = 'Type'       },
      Null          = { icon = '󰟢', hl = 'Type'       },
      EnumMember    = { icon = '', hl = 'Identifier' },
      Struct        = { icon = '󰌗', hl = 'Structure'  },
      Event         = { icon = '', hl = 'Type'       },
      Operator      = { icon = '󰆕', hl = 'Identifier' },
      TypeParameter = { icon = '󰊄', hl = 'Identifier' },
      Component     = { icon = '󰡀', hl = 'Function'   },
      Fragment      = { icon = '󰄉', hl = 'Constant'   },
    },
  },

  keymaps = {
    show_help    = '?',
    close        = { '<Esc>', 'q' },
    goto_location         = '<cr>',
    peek_location         = 'o',
    goto_and_close        = '<S-cr>',
    restore_location      = '<C-g>',
    hover_symbol          = '<C-space>',
    toggle_preview        = 'K',
    rename_symbol         = 'r',
    code_actions          = 'a',
    fold                  = 'h',
    unfold                = 'l',
    fold_toggle           = '<tab>',
    fold_toggle_all       = '<S-tab>',
    fold_all              = 'W',
    unfold_all            = 'E',
    fold_reset            = 'R',
    down_and_goto         = '<C-j>',
    up_and_goto           = '<C-k>',
  },
})

vim.keymap.set('n', '<leader>o', '<cmd>Outline<cr>', {
  desc   = 'Toggle outline panel',
  silent = true,
})
