M = {}

local Config = require("imagepreview.config")
local utils = require("imagepreview.utils")

local Scale = { To_6 = 0, To_12 = 1 }
local overlay_id = -1

local function Create_Dither_Image(Image_Path)

  local braille = require("imagepreview.braille")

  -- term sizes are calculated from image and target window sizes
  -- See config.lua for the latter.
  braille.Create_Preview_Dump(Image_Path)

end

local function Font_Scale(To)

  if To == Scale.To_12 then
    vim.cmd("silent !gsettings set org.gnome.desktop.interface monospace-font-name '" .. Config.base_font .. " 12'")

  elseif To == Scale.To_6 then
    vim.cmd("silent !gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 6'")

  end
end

-- This function Generate the window that will welcome the terminal buffer
-- used to show the preview.
-- Its width/height are a percentage of the UI's final sizes. To know why
-- thoses are precalculated, see config.lua
local function Generate_Preview_Window()

  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local win = Popup({
    enter = true,
    focusable = true,
    relative = "editor",
    zindex = 2,
    border = { style = "rounded" },
    position = "160",
    size = {
      width = tostring(math.floor(Config.UI_target_width * Config.term_width_percentage)),
      height = tostring(math.floor(Config.UI_target_height * Config.term_height_percentage))
    },
  })

  win:on(event.BufLeave, function()
    win:unmount()
    vim.cmd("silent !rm tmp.txt")
    Font_Scale(Scale.To_12)
    vim.api.nvim_win_close(overlay_id, false)
    overlay_id = -1
  end)

  win:mount()

  return win
end

local function Display_Image(win_buffer)

  local chan = vim.api.nvim_open_term(win_buffer, {})

  local data = assert(io.open("tmp.txt", 'r'))
  local line = data:read("*line")
  local line_nb = 0

  while line do
    vim.api.nvim_chan_send(chan, line)
    line = data:read("*line")
    line_nb = line_nb + 1
  end

  data:close()

end

local function Create_Overlay()

  local overlay = {}

  overlay.wincfg = {
    relative = "editor",
    zindex = 1,
    row = 0,
    col = 0,
    width = Config.UI_target_width,
    height = Config.UI_target_height
  }
  overlay.bufid = vim.api.nvim_create_buf(false, true)
  overlay.winid = vim.api.nvim_open_win(overlay.bufid, false, overlay.wincfg)
  vim.wo[overlay.winid].winblend = 10

  return overlay.winid

end

function M.Preview()

  if Config.base_font == "" then
    print("Could not determine base font. Exiting ImagePreview...")
    return
  end

  local ext = { "png", "jpg", "jpeg", "webp" }
  local lib = require("nvim-tree.lib")

  local path = lib.get_node_at_cursor().absolute_path
  local filename = lib.get_node_at_cursor().name

  local file_split = utils.Split(filename, ".")
  local file_ext = file_split[2]
  local has_extension = utils.Length(file_split) > 1

  if has_extension and utils.Has_Value(ext, file_ext) then

    Create_Dither_Image(path)
    local win = Generate_Preview_Window()
    overlay_id = Create_Overlay()
    Display_Image(win.bufnr)

    --  The target window width/height are precalculated for a specific
    --  rescaling (see config.lua). Thus, I can font rescale at the end
    --  to avoid seeing the latence (the terminal refreshing)
    Font_Scale(Scale.To_6)

  else
    print("your file is not an image or is not supported.")
    return
  end
end

return M
