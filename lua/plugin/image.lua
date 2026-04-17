-- =============================================================================
-- plugin/image.lua — Inline image rendering inside Neovim
--
-- image.nvim renders images directly in the terminal using:
--   • Kitty graphics protocol  (recommended, best quality)
--   • ueberzug++ as fallback
--
-- Requirements:
--   • Kitty terminal  OR  ueberzug++ installed
--   • luarocks package: magick  (install with: luarocks install magick)
--
-- To disable image rendering (e.g. when using a terminal that doesn't support
-- it), add 'image' to vim.g.disabled_plugins in init.lua.
-- =============================================================================

vim.pack.add('3rd/image.nvim')

local ok, image = pcall(require, 'image')
if not ok then return end

image.setup({
  backend = 'kitty',        -- 'kitty' | 'ueberzug' | 'none'
  integrations = {
    markdown = {
      enabled                    = true,
      clear_in_insert_mode       = false,
      download_remote_images     = true,
      only_render_image_at_cursor = false,
      filetypes                  = { 'markdown', 'md', 'mdx' },
    },
  },
  max_width              = nil,   -- nil = no limit
  max_height             = nil,
  max_width_window_percentage  = 50,
  max_height_window_percentage = 30,
  window_overlap_clear_enabled = false,
  editor_only_render_when_focused = true,
  tmux_show_only_in_active_window = true,
  hijack_file_patterns   = { '*.png', '*.jpg', '*.jpeg', '*.gif', '*.webp', '*.svg' },
})
