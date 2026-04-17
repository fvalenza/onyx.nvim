-- =============================================================================
-- config/keymaps.lua — Global keymaps
-- These are keymaps that exist independently of any plugin.
-- Plugin-specific keymaps are defined inside each lua/plugin/*.lua file and
-- registered with legendary.nvim so they appear in the command palette.
-- =============================================================================

local map = vim.keymap.set

-- ── General ────────────────────────────────────────────────────────────────
-- Clear search highlight
map('n', '<Esc>', '<cmd>nohlsearch<cr>', { desc = 'Clear search highlight' })

-- Better up/down (respect wrapped lines)
map({ 'n', 'x' }, 'j', "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map({ 'n', 'x' }, 'k', "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })

-- Move lines up/down in visual mode
map('v', 'J', ":m '>+1<cr>gv=gv", { desc = 'Move selection down', silent = true })
map('v', 'K', ":m '<-2<cr>gv=gv", { desc = 'Move selection up', silent = true })

-- Keep cursor centred after search jumps
map('n', 'n', 'nzzzv', { desc = 'Next search result (centred)' })
map('n', 'N', 'Nzzzv', { desc = 'Prev search result (centred)' })

-- Keep cursor position on J (join lines)
map('n', 'J', 'mzJ`z', { desc = 'Join lines (keep cursor)' })

-- ── Windows / splits ───────────────────────────────────────────────────────
map('n', '<C-h>', '<C-w>h', { desc = 'Go to left window' })
map('n', '<C-j>', '<C-w>j', { desc = 'Go to lower window' })
map('n', '<C-k>', '<C-w>k', { desc = 'Go to upper window' })
map('n', '<C-l>', '<C-w>l', { desc = 'Go to right window' })

map('n', '<leader>wv', '<C-w>v',     { desc = 'Split window vertically' })
map('n', '<leader>wh', '<C-w>s',     { desc = 'Split window horizontally' })
map('n', '<leader>wd', '<C-w>c',     { desc = 'Close window' })
map('n', '<leader>wo', '<C-w>o',     { desc = 'Close other windows' })

-- ── Buffers ────────────────────────────────────────────────────────────────
map('n', '<S-l>', '<cmd>bnext<cr>',     { desc = 'Next buffer' })
map('n', '<S-h>', '<cmd>bprevious<cr>', { desc = 'Previous buffer' })
map('n', '<leader>bd', '<cmd>bdelete<cr>', { desc = 'Delete buffer' })

-- ── Save / quit ────────────────────────────────────────────────────────────
map({ 'n', 'i' }, '<C-s>', '<cmd>w<cr><esc>', { desc = 'Save file' })
map('n', '<leader>q', '<cmd>quit<cr>', { desc = 'Quit' })
map('n', '<leader>Q', '<cmd>quitall<cr>', { desc = 'Quit all' })

-- ── Indentation ────────────────────────────────────────────────────────────
-- Stay in visual mode after indent
map('v', '<', '<gv', { desc = 'Indent left (stay in visual)' })
map('v', '>', '>gv', { desc = 'Indent right (stay in visual)' })

-- ── Diagnostics ────────────────────────────────────────────────────────────
map('n', '[d', vim.diagnostic.goto_prev, { desc = 'Previous diagnostic' })
map('n', ']d', vim.diagnostic.goto_next, { desc = 'Next diagnostic' })
map('n', '<leader>cd', vim.diagnostic.open_float, { desc = 'Show diagnostic' })

-- ── Clipboard ──────────────────────────────────────────────────────────────
-- Visual mode: replace selection with clipboard without overwriting the register
map('v', '<leader>p', '"_dP', { desc = 'Paste over selection (keep register)' })

-- ── Spelling ───────────────────────────────────────────────────────────────
map('n', '<leader>ts', '<cmd>setlocal spell!<cr>', { desc = 'Toggle spell check' })
