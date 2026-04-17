# onyx.nvim — Architecture & Plugin Decision Guide

A full Neovim configuration built around a **Markdown / Obsidian-style note-taking** workflow.

---

## Table of Contents

1. [High-level Architecture](#1-high-level-architecture)
2. [Package Manager — `vim.pack`](#2-package-manager--vimpack)
3. [Plugin Auto-Discovery System](#3-plugin-auto-discovery-system)
4. [Core Configuration Files](#4-core-configuration-files)
5. [Plugin Decisions](#5-plugin-decisions)
6. [Note-Editing Workflow](#6-note-editing-workflow)
7. [Lualine Custom Components](#7-lualine-custom-components)
8. [Keymap Reference](#8-keymap-reference)
9. [First-Run Setup](#9-first-run-setup)
10. [Customisation Guide](#10-customisation-guide)

---

## 1. High-level Architecture

```
~/.config/nvim/
├── init.lua                  ← entry point; sets leader, disabled list, loads config + pack
├── readme.md                 ← this file
└── lua/
    ├── pack.lua              ← plugin auto-loader (wraps vim.pack)
    ├── config/
    │   ├── options.lua       ← editor options
    │   ├── keymaps.lua       ← global keymaps (no-plugin)
    │   ├── autocmds.lua      ← autocommands
    │   └── notes.lua         ← vault paths & obsidian CLI helpers
    └── plugin/               ← one file per logical plugin unit
        ├── legendary.lua
        ├── snacks.lua
        ├── treesitter.lua
        ├── render_markdown.lua
        ├── image.lua
        ├── outline.lua
        ├── lualine.lua
        ├── img_clip.lua
        ├── bullets.lua
        ├── notes.lua
        ├── codeblock.lua
        └── eval.lua
```

**Design principle:** every file in `lua/plugin/` is self-contained — it calls
`vim.pack.add(...)` to declare its dependency and configures the plugin in the
same file.  No central "plugin list" file exists; the list *is* the folder
contents.

---

## 2. Package Manager — `vim.pack`

Neovim 0.12 ships a built-in package manager under the `vim.pack` namespace.
It manages plugins in `~/.local/share/nvim/site/pack/vim-pack/` without any
external dependency.

### Key API

```lua
-- Install/declare a single plugin (GitHub shorthand)
vim.pack.add('user/repo')

-- With a version constraint
vim.pack.add({ 'user/repo', version = 'v2.*' })

-- With a full URL
vim.pack.add('https://github.com/user/repo.git')
```

`vim.pack.add` is idempotent: calling it for an already-installed plugin is a
no-op (fast path).  On first run Neovim downloads the plugin automatically.

**Why `vim.pack` over lazy.nvim / packer?**

- Zero external dependencies — works on any machine with Neovim 0.12+
- Simpler mental model: no spec format to learn
- Lazy-loading is handled per-plugin via normal Lua patterns (`pcall`,
  `vim.schedule`, autocmds) rather than a framework
- Faster startup because there is no loader framework to initialise

---

## 3. Plugin Auto-Discovery System

`lua/pack.lua` is the loader.  On startup it:

1. Reads all `*.lua` files from `lua/plugin/` (alphabetical order)
2. Filters out any whose base-name appears in `vim.g.disabled_plugins`
3. `require`s the rest via `plugin.<name>`

### Disabling a plugin

In `init.lua`, add the file's base-name (without `.lua`) to the table:

```lua
vim.g.disabled_plugins = {
  'image',      -- disable image.nvim (no kitty terminal)
  'codeblock',  -- disable code-block executor
}
```

### Adding a new plugin

Create `lua/plugin/my_plugin.lua`, add `vim.pack.add('user/repo')` at the top
and your configuration below.  The loader picks it up automatically on next
startup — no registration anywhere else is needed.

### Load order

Files are loaded alphabetically.  If you need a specific order (e.g. a plugin
that extends treesitter must load after it), prefix the filename with a number:

```
lua/plugin/01_treesitter.lua
lua/plugin/02_treesitter_ext.lua
```

---

## 4. Core Configuration Files

| File | Purpose |
|------|---------|
| `lua/config/options.lua` | All `vim.opt.*` settings |
| `lua/config/keymaps.lua` | Plugin-independent keymaps |
| `lua/config/autocmds.lua` | Autocommands (yank-highlight, trim-whitespace, markdown settings, …) |
| `lua/config/notes.lua` | Vault paths, template names, `build_create_cmd()` helper |

---

## 5. Plugin Decisions

### legendary.nvim — Command Palette

**Choice:** `mrjones2014/legendary.nvim`

- Acts as the single source of truth for all keymaps: every plugin file
  registers its keymaps with legendary so they appear in the palette (`<leader><leader>`)
- Provides a searchable, fuzzy-findable list of commands and keymaps
- Chosen over which-key because it doubles as a command palette (not just a
  hint popup) and integrates well with vim.ui.select / Snacks picker

### snacks.nvim — Picker & Utilities

**Choice:** `folke/snacks.nvim`

- All-in-one collection of small, high-quality utilities
- **Snacks.picker** replaces Telescope for file/grep/buffer/heading search —
  it is faster and requires no additional dependencies
- **Snacks.notifier** replaces vim.notify with a modern floating-window UI
- **Snacks.dashboard** provides a startup screen
- Chosen over Telescope because the problem statement explicitly requests Snacks

#### Heading picker across vault

`lua/plugin/snacks.lua` provides `M.pick_headings()` which launches
`Snacks.picker.grep` with the pattern `^#{1,6} ` scoped to the vault root.
This gives a live, fuzzy-searchable list of every heading in every note.
Confirming a result opens the file and jumps to the exact line.

### render-markdown.nvim — Markdown Rendering

**Choice:** `MeanderingProgrammer/render-markdown.nvim`

- Renders headings, code fences, tables, checkboxes, bullet icons, and callouts
  directly in the buffer without leaving the editor
- Integrates with Treesitter (required) for accurate parsing
- Table rendering (`pipe_table`) aligns columns visually with Unicode box chars
- Toggle via `<leader>tm`; status reflected in the lualine component

### image.nvim — Inline Images

**Choice:** `3rd/image.nvim`

- Renders images inline using the **Kitty graphics protocol** (best quality) or
  ueberzug++ as a fallback
- Requires a compatible terminal emulator (Kitty, WezTerm with kitty protocol)
- Disable by adding `'image'` to `vim.g.disabled_plugins` when using a
  non-supporting terminal

### outline.nvim — Symbol Outline

**Choice:** `hedyhli/outline.nvim`

- Side panel showing the symbol tree of the current file
- For Markdown: shows all headings (h1–h6) — navigate the structure of long
  notes, press Enter to jump to that section
- Toggles with `<leader>o`
- Chosen over aerial.nvim for its cleaner Markdown support

### lualine.nvim — Statusline

**Choice:** `nvim-lualine/lualine.nvim`

- Industry-standard statusline with rich theming
- Extended with two custom components (see §7)
- `nvim-web-devicons` added for file-type icons

### img-clip.nvim — Screenshot Paste

**Choice:** `HakonHarnes/img-clip.nvim`

- Listens for `<leader>pi` (or `:PasteImage`)
- Grabs the image from the system clipboard, saves it as
  `<current-file-dir>/<YYYYMMDD_HHMMSS>.png`, and inserts the Markdown link
- With the **Folder-Note** technique the file's directory *is* the note's asset
  folder, so no extra path logic is needed

### bullets.vim — List Editing

**Choice:** `bullets-vim/bullets.vim`

- Automatic bullet continuation when pressing Enter in a list
- Auto-increment numbered lists
- Checkbox cycle with `<C-Space>`
- Chosen over manual autocmds for its robustness and edge-case handling

**Plus:** `nvim-autopairs` for bracket/quote auto-closing.

### treesitter — Syntax & Text Objects

**Choice:** `nvim-treesitter/nvim-treesitter` + textobjects

- Powers render-markdown, folding, and structural text objects
- Installs `markdown` and `markdown_inline` parsers for accurate tokenisation

---

## 6. Note-Editing Workflow

### Vault Structure

```
~/vault/
├── cheatsheets/          ← cheatsheets
├── templates/            ← note templates (daily.md, moc.md, note.md)
│   ├── daily.md
│   ├── moc.md
│   └── note.md
└── vault/                ← actual notes
    ├── 0-dailynotes/
    ├── 1-MOCs/
    └── 2-notes/
```

### Folder-Note Technique

Each note lives inside a folder of the same name:

```
vault/2-notes/
└── my-topic/
    ├── my-topic.md     ← the note itself
    ├── diagram.png     ← assets referenced inside the note
    └── screenshot.png
```

This makes sharing a note trivial: zip the folder and send it — everything is
self-contained.

### Creating Notes

All note-creation actions prompt for input and call the **Obsidian CLI**:

```
obsidian create template=<name> path=<dest>/<note-name>/<note-name>.md
```

| Action | Keymap | Destination | Template |
|--------|--------|-------------|----------|
| Daily note | `<leader>nd` | `0-dailynotes/YYYY-MM-DD/` | `daily` |
| MOC | `<leader>nm` | `1-MOCs/<name>/` | `moc` |
| New note | `<leader>nn` | prompts for type | depends |

The daily note name defaults to today's date (`YYYY-MM-DD`); no prompt needed.
For MOC and basic notes a `vim.ui.input` popup asks for the note name.

### Screenshot Workflow

1.  Take screenshot → it lands in the OS clipboard
2.  In the note file press `<leader>pi`
3.  img-clip saves the image to the note's own folder and inserts
    `![](./20240115_143022.png)` at the cursor

### Code Block Execution

Fenced code blocks (any language) can be executed as shell commands:

```markdown
```obsidian
obsidian list vault
```
```

- `<leader>xe` — run the block, store output
- `<leader>xt` — toggle: show output as virtual text below the closing fence /
  hide and show the code block again
- `<leader>xc` — discard stored output

The lualine `EXEC` indicator is visible whenever any block in the current
buffer has its output displayed.

### Expression Evaluation

Select any Lua/math expression in visual mode and press `<leader>ev`:

```
Select:   2 + 3 * 4
Result:   = 14
```

Works for any valid Lua expression (`math.sqrt(2)`, `string.rep('x', 5)`, …).
Results appear in the Snacks notifier and in the command line.

---

## 7. Lualine Custom Components

| Component | Display | Meaning |
|-----------|---------|---------|
| `render_markdown_status` | `󰑊 MD` (blue) | render-markdown is **on** |
| `render_markdown_status` | `󰑊` (dim) | render-markdown is **off** |
| `codeblock_status` | `󰐊 EXEC` (amber) | ≥1 code block showing result |
| `codeblock_status` | _(empty)_ | no active result display |

The filename component shows the path relative to the vault root when the
current file is inside the vault.

---

## 8. Keymap Reference

### Notes

| Key | Action |
|-----|--------|
| `<leader>nd` | Create daily note |
| `<leader>nm` | Create MOC |
| `<leader>nn` | Create new note (prompts template + name) |
| `<leader>pi` | Paste screenshot into note |

### Navigation / Search (Snacks)

| Key | Action |
|-----|--------|
| `<leader>ff` | Find files |
| `<leader>fg` | Grep in vault |
| `<leader>fh` | Search headings across vault |
| `<leader>fb` | Open buffers |
| `<leader>fr` | Recent files |
| `<leader>o` | Toggle outline panel |

### Markdown

| Key | Action |
|-----|--------|
| `<leader>tm` | Toggle markdown rendering |

### Code Blocks

| Key | Action |
|-----|--------|
| `<leader>xe` | Execute block under cursor |
| `<leader>xt` | Toggle result / code view |
| `<leader>xc` | Clear stored result |

### Expression Eval

| Key | Mode | Action |
|-----|------|--------|
| `<leader>ev` | visual | Evaluate selected expression |
| `<leader>eE` | normal | Evaluate current line |

### Command Palette

| Key | Action |
|-----|--------|
| `<leader><leader>` | Open Legendary command palette |

---

## 9. First-Run Setup

1. **Install Neovim ≥ 0.12**

2. **Copy this config** to `~/.config/nvim/` (or symlink the repo)

3. **Set your vault path** in `lua/config/notes.lua`:
   ```lua
   M.vault_path = vim.fn.expand('~/path/to/your/vault')
   ```

4. **Install the Obsidian CLI** and ensure it is on `$PATH`.  Adjust
   `M.obsidian_bin` in `lua/config/notes.lua` if needed.

5. **Image support (optional):** use the Kitty terminal emulator and install
   the `magick` Lua rock:
   ```bash
   luarocks install magick
   ```
   If you prefer not to use image rendering, add `'image'` to
   `vim.g.disabled_plugins` in `init.lua`.

6. **Launch Neovim.**  On first start `vim.pack` downloads all plugins
   automatically; treesitter parsers are compiled after that.

---

## 10. Customisation Guide

### Disabling a plugin

```lua
-- init.lua
vim.g.disabled_plugins = { 'image', 'eval' }
```

### Adding a plugin

Create `lua/plugin/my_plugin.lua`:

```lua
vim.pack.add('user/my-plugin.nvim')

local ok, p = pcall(require, 'my-plugin')
if not ok then return end

p.setup({ ... })

vim.keymap.set('n', '<leader>mp', p.do_thing, { desc = 'My plugin: do thing' })
```

The loader picks it up automatically; no other file needs to be changed.

### Changing the vault path

Edit `lua/config/notes.lua`.  All paths derive from `M.vault_path`.

### Changing templates

1. Edit `M.templates` in `lua/config/notes.lua`
2. Add corresponding template files under `~/vault/templates/`

### Changing leader key

Set `vim.g.mapleader` in `init.lua` **before** `require('pack').setup()`.
