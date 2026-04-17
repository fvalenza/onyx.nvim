-- =============================================================================
-- plugin/treesitter.lua — Treesitter (syntax, folds, text-objects)
--
-- Installed first because render-markdown and other plugins depend on it.
-- =============================================================================

vim.pack.add('nvim-treesitter/nvim-treesitter')
vim.pack.add('nvim-treesitter/nvim-treesitter-textobjects')

local ok, ts = pcall(require, 'nvim-treesitter.configs')
if not ok then return end

ts.setup({
  -- Parsers to install automatically
  ensure_installed = {
    'bash', 'c', 'css', 'html', 'json', 'jsonc',
    'lua', 'luadoc', 'markdown', 'markdown_inline',
    'python', 'regex', 'toml', 'vim', 'vimdoc', 'yaml',
  },
  sync_install = false,
  auto_install = true,

  highlight = {
    enable                            = true,
    -- Disable for very large files
    disable = function(_, buf)
      local max_size = 500 * 1024 -- 500 KB
      local ok2, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(buf))
      return ok2 and stats and stats.size > max_size
    end,
    additional_vim_regex_highlighting = false,
  },

  indent = { enable = true },

  incremental_selection = {
    enable = true,
    keymaps = {
      init_selection    = '<C-space>',
      node_incremental  = '<C-space>',
      scope_incremental = false,
      node_decremental  = '<bs>',
    },
  },

  textobjects = {
    select = {
      enable    = true,
      lookahead = true,
      keymaps = {
        ['af'] = '@function.outer',
        ['if'] = '@function.inner',
        ['ac'] = '@class.outer',
        ['ic'] = '@class.inner',
        ['aa'] = '@parameter.outer',
        ['ia'] = '@parameter.inner',
      },
    },
    move = {
      enable              = true,
      set_jumps           = true,
      goto_next_start     = { [']f'] = '@function.outer', [']c'] = '@class.outer' },
      goto_next_end       = { [']F'] = '@function.outer', [']C'] = '@class.outer' },
      goto_previous_start = { ['[f'] = '@function.outer', ['[c'] = '@class.outer' },
      goto_previous_end   = { ['[F'] = '@function.outer', ['[C'] = '@class.outer' },
    },
  },
})
