local function Create_Dither_Image()
  local Image_Id = vim.api.nvim_get_current_buf()
  local Image_Path = vim.api.nvim_buf_get_name(Image_Id)

  --  70, 49 are the term sizes
  vim.cmd("silent !ascii-image-converter -C -b -d 70,49 " .. Image_Path .. "> tmp.txt")
end

local function Generate_Window()
  local Popup = require("nui.popup")
  local event = require("nui.utils.autocmd").event

  local win = Popup({
    enter = true,
    focusable = true,
    border = { style = "rounded" },
    position = "50%",
    size = { width = "44.5%", height = "100%" },
  })

  win:mount()
  win:on(event.BufLeave, function()
    win:unmount()
    vim.cmd("silent !rm tmp.txt")
    vim.cmd("BufDel")
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

vim.api.nvim_create_autocmd("BufEnter", {
  pattern = { "*.png", "*.jpg", "*.jpeg", "*.webp" },
  callback = function()
    Create_Dither_Image()
    local win = Generate_Window()
    Display_Image(win.bufnr)
  end
})
