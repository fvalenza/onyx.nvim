-- =============================================================================
-- config/autocmds.lua — Autocommands
-- =============================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- ── Highlight on yank ──────────────────────────────────────────────────────
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group    = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = 250 })
  end,
})

-- ── Strip trailing whitespace on save ──────────────────────────────────────
augroup('TrimWhitespace', { clear = true })
autocmd('BufWritePre', {
  group   = 'TrimWhitespace',
  pattern = '*',
  callback = function()
    local save = vim.fn.winsaveview()
    vim.cmd([[%s/\s\+$//e]])
    vim.fn.winrestview(save)
  end,
})

-- ── Markdown-specific settings ─────────────────────────────────────────────
augroup('MarkdownSettings', { clear = true })
autocmd('FileType', {
  group   = 'MarkdownSettings',
  pattern = { 'markdown', 'md' },
  callback = function()
    local buf = vim.api.nvim_get_current_buf()
    vim.bo[buf].spell      = true
    vim.bo[buf].textwidth  = 0        -- no hard wrap
    vim.wo.wrap            = true
    vim.wo.linebreak       = true
    vim.wo.breakindent     = true
    vim.wo.conceallevel    = 2
  end,
})

-- ── Resize splits when terminal window is resized ──────────────────────────
augroup('ResizeSplits', { clear = true })
autocmd('VimResized', {
  group    = 'ResizeSplits',
  callback = function()
    vim.cmd('tabdo wincmd =')
  end,
})

-- ── Return to last cursor position when opening a file ─────────────────────
augroup('RestoreCursor', { clear = true })
autocmd('BufReadPost', {
  group    = 'RestoreCursor',
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local line_count = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= line_count then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- ── Auto-create parent directories on save ─────────────────────────────────
augroup('AutoMkdir', { clear = true })
autocmd('BufWritePre', {
  group    = 'AutoMkdir',
  callback = function(ev)
    local dir = vim.fn.fnamemodify(ev.file, ':p:h')
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, 'p')
    end
  end,
})

-- ── Close helper windows with 'q' ──────────────────────────────────────────
augroup('CloseWithQ', { clear = true })
autocmd('FileType', {
  group   = 'CloseWithQ',
  pattern = { 'help', 'qf', 'man', 'notify', 'lspinfo', 'checkhealth' },
  callback = function(ev)
    vim.keymap.set('n', 'q', '<cmd>close<cr>', { buffer = ev.buf, silent = true })
  end,
})
