-- =============================================================================
-- config/options.lua — Neovim editor options
-- =============================================================================

local opt = vim.opt

-- ── UI ─────────────────────────────────────────────────────────────────────
opt.number         = true          -- absolute line numbers
opt.relativenumber = true          -- relative line numbers
opt.signcolumn     = 'yes'         -- always show sign column (no layout shifts)
opt.cursorline     = true          -- highlight current line
opt.colorcolumn    = '100'         -- soft ruler
opt.termguicolors  = true          -- true-colour support
opt.laststatus     = 3             -- global status line (Neovim 0.7+)
opt.showmode       = false         -- mode shown in lualine instead
opt.cmdheight      = 1
opt.pumheight      = 12            -- max items in completion popup

-- ── Folds ──────────────────────────────────────────────────────────────────
opt.foldmethod     = 'expr'
opt.foldexpr       = 'nvim_treesitter#foldexpr()'
opt.foldlevelstart = 99            -- open all folds by default

-- ── Indentation ────────────────────────────────────────────────────────────
opt.expandtab      = true          -- spaces instead of tabs
opt.shiftwidth     = 2
opt.tabstop        = 2
opt.softtabstop    = 2
opt.smartindent    = true

-- ── Search ─────────────────────────────────────────────────────────────────
opt.ignorecase     = true
opt.smartcase      = true          -- override ignorecase when uppercase used
opt.hlsearch       = true
opt.incsearch      = true

-- ── Files ──────────────────────────────────────────────────────────────────
opt.encoding       = 'utf-8'
opt.fileencoding   = 'utf-8'
opt.undofile       = true          -- persistent undo
opt.swapfile       = false
opt.backup         = false
opt.autoread       = true          -- reload file if changed outside neovim

-- ── Splits ─────────────────────────────────────────────────────────────────
opt.splitbelow     = true
opt.splitright     = true

-- ── Clipboard ──────────────────────────────────────────────────────────────
opt.clipboard      = 'unnamedplus' -- use system clipboard

-- ── Scroll / navigation ────────────────────────────────────────────────────
opt.scrolloff      = 8             -- keep 8 lines visible around cursor
opt.sidescrolloff  = 8

-- ── Completion ─────────────────────────────────────────────────────────────
opt.completeopt    = { 'menu', 'menuone', 'noselect' }

-- ── Conceal (for markdown) ─────────────────────────────────────────────────
opt.conceallevel   = 2             -- conceal markdown syntax where possible

-- ── Wrap ───────────────────────────────────────────────────────────────────
opt.wrap           = true
opt.linebreak      = true          -- wrap at word boundary
opt.breakindent    = true          -- wrapped lines respect indentation

-- ── Spell ──────────────────────────────────────────────────────────────────
opt.spelllang      = 'en'
-- Spell is toggled per buffer via keymap / autocmd for markdown files.

-- ── Misc ───────────────────────────────────────────────────────────────────
opt.mouse          = 'a'
opt.updatetime     = 200           -- faster CursorHold events
opt.timeoutlen     = 400           -- which-key popup delay
opt.virtualedit    = 'block'       -- allow cursor beyond EOL in visual-block
opt.inccommand     = 'split'       -- live preview of :substitute

-- Neovim 0.10+: enable inline diagnostic virtual text
if vim.diagnostic and vim.diagnostic.config then
  vim.diagnostic.config({
    virtual_text = true,
    signs        = true,
    underline    = true,
    update_in_insert = false,
    severity_sort = true,
  })
end
