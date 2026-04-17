-- =============================================================================
-- plugin/notes.lua — Note creation workflow via the Obsidian CLI
--
-- Workflow
-- ────────
-- 1.  User triggers a note-type action (daily / MOC / basic note)
-- 2.  For MOC and basic notes: user is prompted for a filename
-- 3.  The Obsidian CLI is called:
--       obsidian create template=<tpl> path=<dest>/<name>/<name>.md
-- 4.  Neovim opens the created file
--
-- Folder-Note technique
-- ─────────────────────
-- Each note lives inside a folder of the same name:
--   vault/2-notes/my-topic/my-topic.md
-- Assets (images etc.) are stored alongside the .md file in that folder.
--
-- Configuration
-- ─────────────
-- See lua/config/notes.lua for path / template settings.
-- =============================================================================

local M = {}

local cfg = require('config.notes')

-- Run a shell command and return (success, output).
local function run(cmd)
  local handle = io.popen(cmd .. ' 2>&1')
  if not handle then return false, 'io.popen failed' end
  local output = handle:read('*a')
  local ok     = handle:close()
  return ok, output
end

-- Open a file in Neovim (create parent dirs first if necessary).
local function open_file(path)
  local dir = vim.fn.fnamemodify(path, ':h')
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, 'p')
  end
  vim.cmd('edit ' .. vim.fn.fnameescape(path))
end

-- Execute the Obsidian CLI to create a note, then open it.
-- @param template  string   template name (daily | moc | note)
-- @param dest_dir  string   destination folder path
-- @param name      string   note name (without extension)
local function create_and_open(template, dest_dir, name)
  local cmd  = cfg.build_create_cmd(template, dest_dir, name)
  local ok, out = run(cmd)

  local note_path = string.format('%s/%s/%s.md', dest_dir, name, name)

  if ok then
    vim.notify(string.format('Note created: %s', note_path), vim.log.levels.INFO)
    open_file(note_path)
  else
    -- Obsidian CLI failed – warn but still open the file (user can fill it in)
    vim.notify(
      string.format('obsidian CLI warning (creating anyway):\n%s', out),
      vim.log.levels.WARN
    )
    open_file(note_path)
  end
end

-- Prompt for a name using vim.ui.input, then call callback.
local function prompt_name(label, default, callback)
  vim.ui.input({ prompt = label, default = default }, function(input)
    if not input or input == '' then
      vim.notify('Aborted – no name provided.', vim.log.levels.WARN)
      return
    end
    -- Sanitise: replace spaces with hyphens, lower-case
    local name = input:gsub('%s+', '-')
    callback(name)
  end)
end

-- ── Public API ──────────────────────────────────────────────────────────────

--- Create today's daily note (name defaults to YYYY-MM-DD).
function M.create_daily()
  local name = cfg.today()
  create_and_open(cfg.templates.daily, cfg.daily_path, name)
end

--- Prompt for a MOC name, then create the MOC note.
function M.create_moc()
  prompt_name('MOC name: ', '', function(name)
    create_and_open(cfg.templates.moc, cfg.moc_path, name)
  end)
end

--- Prompt for template + name, then create a basic note.
function M.create_note()
  -- Step 1: choose template
  local template_keys = vim.tbl_keys(cfg.templates)
  table.sort(template_keys)

  vim.ui.select(template_keys, {
    prompt = 'Select template › ',
    format_item = function(k) return k .. '  (' .. cfg.templates[k] .. ')' end,
  }, function(choice)
    if not choice then return end
    local template = cfg.templates[choice]

    -- Step 2: choose destination folder based on template
    local dest_dir
    if choice == 'daily' then
      dest_dir = cfg.daily_path
    elseif choice == 'moc' then
      dest_dir = cfg.moc_path
    else
      dest_dir = cfg.basic_path
    end

    -- Step 3: prompt for name
    prompt_name('Note name: ', '', function(name)
      create_and_open(template, dest_dir, name)
    end)
  end)
end

-- ── Keymaps ─────────────────────────────────────────────────────────────────
vim.keymap.set('n', '<leader>nd', M.create_daily, { desc = 'Notes: create daily note', silent = true })
vim.keymap.set('n', '<leader>nm', M.create_moc,   { desc = 'Notes: create MOC',        silent = true })
vim.keymap.set('n', '<leader>nn', M.create_note,  { desc = 'Notes: create new note',   silent = true })

-- User commands
vim.api.nvim_create_user_command('NotesDaily', M.create_daily,  { desc = 'Create/open today\'s daily note' })
vim.api.nvim_create_user_command('NotesMOC',   M.create_moc,    { desc = 'Create a new MOC note' })
vim.api.nvim_create_user_command('NotesNew',   M.create_note,   { desc = 'Create a new note (prompts template + name)' })

return M
