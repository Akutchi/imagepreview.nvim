M = {}

local Config = require("imagepreview.config")
local utils = require("imagepreview.utils")

local function Create_Dither_Image(Image_Path, file_ext)
  local braille = require("imagepreview.braille")

  -- term sizes are calculated from image and window sizes
  braille.Create_Tmp(Image_Path)
end

local function Generate_Window()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local win = Popup({
    enter = true,
    focusable = true,
    relative = "editor",
    border = { style = "rounded" },
    position = "180%",
    size = { width = tostring(math.floor(Config.target_width * Config.term_width_percentage)), height = tostring(math.floor(Config.target_height * Config.term_height_percentage)) },
  })

  win:mount()
  win:on(event.BufLeave, function()
    win:unmount()
    vim.cmd("silent !rm tmp.txt")
    vim.cmd("silent !gsettings set org.gnome.desktop.interface monospace-font-name '0xProto Nerd Font 12'")
  end)

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

function M.Preview()
  local ext = { "png", "jpg", "jpeg", "webp" }
  local lib = require("nvim-tree.lib")
  local path = lib.get_node_at_cursor().absolute_path
  local filename = lib.get_node_at_cursor().name

  local file_split = utils.Split(filename, ".")
  local file_ext = file_split[2]
  local len = utils.Length(file_split)


  if (len > 1) and utils.Has_Value(ext, file_ext) then
    --  The target window width/height are precalculated for a specific rescaling
    --  Thus, I can font rescale at the end to avoid seeing the latence
    Create_Dither_Image(path, file_ext)
    local win = Generate_Window()
    Display_Image(win.bufnr)
    vim.cmd("silent !gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 6'")
  else
    print("your file is not an image or is not supported.")
    return
  end
end

return M
