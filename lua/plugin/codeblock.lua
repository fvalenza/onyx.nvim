-- =============================================================================
-- plugin/codeblock.lua — Code block execution with toggle display
--
-- Behaviour
-- ─────────
-- • Place cursor anywhere inside (or on the opening fence of) a fenced code
--   block in a Markdown file.
-- • <leader>xe  — Execute the block as a shell command and store the output.
-- • <leader>xt  — Toggle between showing the code block and showing its output
--   as virtual text below the closing fence.
-- • <leader>xc  — Clear / discard stored output for the block under cursor.
--
-- Primary use-case: Obsidian CLI snippets.  A block like:
--
--   ```obsidian
--   obsidian list vault
--   ```
--
-- … is run as  $ obsidian list vault  and the output is displayed inline.
--
-- Lualine status
-- ──────────────
-- M.result_mode_active() returns true if the current buffer has any block
-- whose output is currently being displayed (used by lualine component).
-- =============================================================================

local M = {}

-- Storage: keyed by  bufnr → { [block_start_line] = { output, showing } }
local store = {}

-- ── Helpers ─────────────────────────────────────────────────────────────────

-- Find the fenced code block that surrounds (or starts at) the cursor line.
-- Returns  (start_line, end_line, lang, body_lines)  or nil.
-- start_line / end_line are 1-based.
local function find_block_at_cursor()
  local buf    = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)[1] -- 1-based
  local lines  = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  local total  = #lines

  -- Find the opening fence at or before the cursor
  local open_line, lang
  for i = cursor, 1, -1 do
    local l = lines[i]
    local m_lang = l:match('^```(%w*)')
    if m_lang ~= nil then
      open_line = i
      lang      = m_lang ~= '' and m_lang or 'sh'
      break
    end
  end
  if not open_line then return nil end

  -- Find the closing fence after the opening one
  local close_line
  for i = open_line + 1, total do
    if lines[i]:match('^```%s*$') then
      close_line = i
      break
    end
  end
  if not close_line then return nil end

  -- Make sure cursor is actually between the fences
  if cursor < open_line or cursor > close_line then return nil end

  -- Extract body
  local body = {}
  for i = open_line + 1, close_line - 1 do
    body[#body + 1] = lines[i]
  end

  return open_line, close_line, lang, body
end

-- Namespace for virtual text
local ns = vim.api.nvim_create_namespace('codeblock_result')

-- Render (or clear) virtual text for a stored result.
local function render_vt(buf, close_line, entry)
  -- Always clear previous vt for this range
  vim.api.nvim_buf_clear_namespace(buf, ns, close_line - 1, close_line)

  if not entry.showing or not entry.output then return end

  local lines = vim.split(entry.output, '\n', { plain = true })
  -- Trim trailing empty lines
  while #lines > 0 and lines[#lines]:match('^%s*$') do
    table.remove(lines)
  end

  local vt_lines = {}
  for _, ln in ipairs(lines) do
    vt_lines[#vt_lines + 1] = { { '  ' .. ln, 'Comment' } }
  end
  if #vt_lines == 0 then
    vt_lines = { { { '  (no output)', 'Comment' } } }
  end

  -- Insert virtual lines below the closing fence
  vim.api.nvim_buf_set_extmark(buf, ns, close_line - 1, 0, {
    virt_lines         = vt_lines,
    virt_lines_above   = false,
  })
end

-- ── Public API ──────────────────────────────────────────────────────────────

--- Execute the code block under the cursor.
function M.execute_block()
  local open_line, close_line, lang, body = find_block_at_cursor()
  if not open_line then
    vim.notify('No fenced code block found at cursor', vim.log.levels.WARN)
    return
  end

  local cmd = table.concat(body, '\n')
  if cmd:match('^%s*$') then
    vim.notify('Code block is empty', vim.log.levels.WARN)
    return
  end

  vim.notify(string.format('Executing [%s] block…', lang), vim.log.levels.INFO)

  -- Run asynchronously using vim.system (Neovim 0.10+) or fallback
  local function on_done(result)
    local output = (result.stdout or '') .. (result.stderr or '')
    if output == '' then output = '(no output)' end

    local buf = vim.api.nvim_get_current_buf()
    store[buf] = store[buf] or {}
    store[buf][open_line] = {
      output    = output,
      showing   = true,
      close_line = close_line,
    }

    vim.schedule(function()
      render_vt(buf, close_line, store[buf][open_line])
      vim.notify('Block executed.', vim.log.levels.INFO)
    end)
  end

  if vim.system then
    vim.system({ 'sh', '-c', cmd }, { text = true }, on_done)
  else
    -- Fallback: synchronous execution
    local handle = io.popen(cmd .. ' 2>&1')
    local output = handle and handle:read('*a') or '(failed to execute)'
    if handle then handle:close() end
    on_done({ stdout = output, stderr = '' })
  end
end

--- Toggle display: show output virtual text ↔ show nothing.
function M.toggle_result()
  local open_line, close_line = find_block_at_cursor()
  if not open_line then
    vim.notify('No fenced code block found at cursor', vim.log.levels.WARN)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  local entry = store[buf] and store[buf][open_line]

  if not entry then
    vim.notify('No result stored – run <leader>xe first', vim.log.levels.WARN)
    return
  end

  entry.showing = not entry.showing
  render_vt(buf, close_line, entry)
end

--- Discard stored result and clear virtual text.
function M.clear_result()
  local open_line, close_line = find_block_at_cursor()
  if not open_line then return end

  local buf = vim.api.nvim_get_current_buf()
  if store[buf] then
    store[buf][open_line] = nil
  end
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)
  vim.notify('Result cleared', vim.log.levels.INFO)
end

--- Used by lualine: returns true if ANY block in current buf is showing output.
function M.result_mode_active()
  local buf   = vim.api.nvim_get_current_buf()
  local bufe  = store[buf]
  if not bufe then return false end
  for _, entry in pairs(bufe) do
    if entry.showing then return true end
  end
  return false
end

-- ── Keymaps ─────────────────────────────────────────────────────────────────
vim.keymap.set('n', '<leader>xe', M.execute_block,  { desc = 'Execute code block',              silent = true })
vim.keymap.set('n', '<leader>xt', M.toggle_result,  { desc = 'Toggle code block / result view', silent = true })
vim.keymap.set('n', '<leader>xc', M.clear_result,   { desc = 'Clear code block result',         silent = true })

return M
