M = {}

local utils = require("imagepreview.utils")

local function Create_Dither_Image(Image_Path)
  --  70, 49 are the term sizes
  vim.cmd("silent !ascii-image-converter -C -b -d 70,49 " .. Image_Path .. "> tmp.txt")
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
    size = { width = "44.5%", height = "100%" },
  })

  win:mount()
  win:on(event.BufLeave, function()
    win:unmount()
    vim.cmd("silent !rm tmp.txt")
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
  local len = utils.Length(file_split)

  if (len > 1) and utils.Has_Value(ext, file_split[2]) then
    Create_Dither_Image(path)
    local win = Generate_Window()
    Display_Image(win.bufnr)
  else
    print("your file is not an image or is not supported")
    return
  end
end

return M
