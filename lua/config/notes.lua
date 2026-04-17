-- =============================================================================
-- config/notes.lua — Note workflow configuration
--
-- All paths are configurable here.  Edit vault_path to point to your vault.
-- =============================================================================

local M = {}

-- ── Vault root ─────────────────────────────────────────────────────────────
M.vault_path      = vim.fn.expand('~/vault')

-- ── Sub-directories ────────────────────────────────────────────────────────
M.templates_path  = M.vault_path .. '/templates'
M.cheatsheets_path = M.vault_path .. '/cheatsheets'

-- Notes live under vault/vault/<type>/
M.notes_root      = M.vault_path .. '/vault'
M.daily_path      = M.notes_root .. '/0-dailynotes'
M.moc_path        = M.notes_root .. '/1-MOCs'
M.basic_path      = M.notes_root .. '/2-notes'

-- ── Templates ──────────────────────────────────────────────────────────────
-- Matches the template name passed to `obsidian create template=<name>`
M.templates = {
  daily = 'daily',
  moc   = 'moc',
  note  = 'note',
}

-- ── Obsidian CLI ───────────────────────────────────────────────────────────
-- Path to the obsidian CLI binary.  Override if it is not on $PATH.
M.obsidian_bin = 'obsidian'

-- Build the CLI command to create a note via a template.
-- The Folder-Note technique places each note inside its own same-name folder:
--   <destination_dir>/<name>/<name>.md
--
-- @param template  string  template name (key in M.templates)
-- @param dest_dir  string  destination directory (daily_path / moc_path / …)
-- @param name      string  note name (without extension)
-- @return          string  shell command to execute
function M.build_create_cmd(template, dest_dir, name)
  local path = string.format('%s/%s/%s.md', dest_dir, name, name)
  return string.format(
    '%s create template=%s path=%s',
    M.obsidian_bin,
    vim.fn.shellescape(template),
    vim.fn.shellescape(path)
  )
end

-- Convenience: return today's date string used as the daily note name.
function M.today()
  return os.date('%Y-%m-%d')
end

return M
