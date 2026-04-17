-- =============================================================================
-- plugin/img_clip.lua — Paste screenshots (clipboard images) into notes
--
-- img-clip.nvim listens for a "paste image" action, grabs the image from the
-- system clipboard, saves it as a file next to the current markdown note, and
-- inserts the Markdown image link.
--
-- With the Folder-Note technique the current file is already inside its own
-- folder (e.g.  vault/2-notes/my-note/my-note.md), so images are stored in
-- the same folder as the note: vault/2-notes/my-note/<timestamp>.png
-- =============================================================================

vim.pack.add('HakonHarnes/img-clip.nvim')

local ok, img_clip = pcall(require, 'img-clip')
if not ok then return end

img_clip.setup({
  default = {
    -- Save image in the same directory as the currently open file.
    -- This means for a folder-note  notes/my-topic/my-topic.md  the image
    -- lands in  notes/my-topic/<datetime>.png  — right next to the note.
    dir_path = function()
      return vim.fn.expand('%:p:h')
    end,

    -- Unique file name based on date-time to avoid collisions
    file_name = function()
      return os.date('%Y%m%d_%H%M%S')
    end,

    -- Use relative path in the generated Markdown link
    use_absolute_path = false,

    -- Prompt for a custom alt-text / caption
    prompt_for_file_name = false,

    -- Markdown link template:  ![alt](path)
    template = '![$CURSOR]($FILE_PATH)',

    -- Drag-and-drop support
    drag_and_drop = {
      enabled    = true,
      insert_mode = true,
    },
  },

  -- Per-filetype overrides
  filetypes = {
    markdown = {
      url_encode_path    = true,
      template           = '![$CURSOR]($FILE_PATH)',
      download_images    = false,
    },
  },
})

vim.keymap.set({ 'n', 'v', 'i' }, '<leader>pi', '<cmd>PasteImage<cr>', {
  desc   = 'Paste screenshot / clipboard image into note',
  silent = true,
})
