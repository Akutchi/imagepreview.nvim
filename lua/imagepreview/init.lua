M = {}

local utils = require("imagepreview.utils")

local function Create_Dither_Image(Image_Path, file_ext)
  local braille = require("imagepreview.braille")

  --  57, 47 are the term sizes
  braille.Create_Tmp(57, 47, Image_Path)
end

local function Generate_Window()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local win = Popup({
    enter = true,
    focusable = true,
    relative = "editor",
    border = { style = "rounded" },
    position = "50%",
    size = { width = "30%", height = "95%" },
  })

  win:mount()
  win:on(event.BufLeave, function()
    win:unmount()
    vim.cmd("silent !rm tmp.txt")
    vim.cmd("silent !gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 12'")
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
    vim.cmd("silent !gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 6'")
    Create_Dither_Image(path, file_ext)
    local win = Generate_Window()
    Display_Image(win.bufnr)
  else
    print("your file is not an image or is not supported.")
    return
  end
end

return M
