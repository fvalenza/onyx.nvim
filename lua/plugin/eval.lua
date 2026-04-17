-- =============================================================================
-- plugin/eval.lua — Lua expression evaluator for visual selections / lines
--
-- Use-case: evaluate small math expressions or Lua snippets that appear in
-- your notes (e.g. select  "2 + 3 * 4"  and press <leader>ev to see "14").
--
-- The result is shown via vim.notify (Snacks notifier) and also echoed so it
-- is visible in the command line.
-- =============================================================================

local M = {}

-- Safely evaluate a Lua expression string.
-- Tries `return <expr>` first; if that fails, tries the raw string.
-- Returns (ok, result_or_error).
local function safe_eval(code)
  -- Try as expression first (e.g. "2+3", "math.sqrt(2)")
  local fn, err = load('return ' .. code)
  if not fn then
    -- Fall back to statement (e.g. "print('hi')")
    fn, err = load(code)
  end
  if not fn then
    return false, 'Compile error: ' .. (err or 'unknown')
  end
  local ok, result = pcall(fn)
  if not ok then
    return false, 'Runtime error: ' .. tostring(result)
  end
  return true, result
end

-- Get the text of the current visual selection.
local function get_visual_selection()
  -- Re-enter normal mode to finalise selection marks
  local _, ls, cs = unpack(vim.fn.getpos("'<"))
  local _, le, ce = unpack(vim.fn.getpos("'>"))
  local lines = vim.api.nvim_buf_get_lines(0, ls - 1, le, false)
  if #lines == 0 then return '' end
  -- Trim to exact column selection (single-line aware)
  if #lines == 1 then
    lines[1] = lines[1]:sub(cs, ce)
  else
    lines[1]    = lines[1]:sub(cs)
    lines[#lines] = lines[#lines]:sub(1, ce)
  end
  return table.concat(lines, '\n')
end

-- Show result in a small floating window.
local function show_result(input, result)
  local text = tostring(result)
  local msg  = string.format('= %s', text)

  -- Notify via Snacks / vim.notify
  vim.notify(msg, vim.log.levels.INFO, { title = 'Eval › ' .. input:sub(1, 40) })

  -- Also echo to command line for quick visibility
  vim.api.nvim_echo({ { msg, 'MoreMsg' } }, false, {})
end

-- ── Public API ──────────────────────────────────────────────────────────────

--- Evaluate the current visual selection as a Lua expression.
function M.eval_selection()
  -- Must be called from a mapping that exits visual mode first (<leader>ev)
  vim.schedule(function()
    local code = get_visual_selection()
    code = code:gsub('%s+', ' '):match('^%s*(.-)%s*$') -- trim
    if code == '' then
      vim.notify('Nothing selected to evaluate', vim.log.levels.WARN)
      return
    end
    local ok, result = safe_eval(code)
    if ok then
      show_result(code, result)
    else
      vim.notify(result, vim.log.levels.ERROR, { title = 'Eval error' })
    end
  end)
end

--- Evaluate the expression on the current line.
function M.eval_line()
  local line = vim.api.nvim_get_current_line()
  line = line:match('^%s*(.-)%s*$') -- trim
  if line == '' then
    vim.notify('Empty line', vim.log.levels.WARN)
    return
  end
  local ok, result = safe_eval(line)
  if ok then
    show_result(line, result)
  else
    vim.notify(result, vim.log.levels.ERROR, { title = 'Eval error' })
  end
end

-- ── Keymaps ─────────────────────────────────────────────────────────────────
-- Visual-mode evaluation: press <leader>ev while text is selected
vim.keymap.set('v', '<leader>ev', function()
  -- Exit visual mode, then schedule so marks are set
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false)
  M.eval_selection()
end, { desc = 'Eval: evaluate Lua expression (selection)', silent = true })

-- Normal-mode: evaluate current line
vim.keymap.set('n', '<leader>eE', M.eval_line, { desc = 'Eval: evaluate Lua expression (line)', silent = true })

return M
