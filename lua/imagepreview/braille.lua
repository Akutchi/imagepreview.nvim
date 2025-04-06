M = {}

local Config = require("imagepreview.config")
local utils = require("imagepreview.utils")

local StartSet = "\x1b[38;2;"
local EndSet = "\x1b[0m"

--  from https://rosettacode.org/wiki/Bitmap/Read_a_PPM_file#Lua
--  Modified to change the processing order
function Read_PPM(filename)
  local fp = io.open(filename, "rb")
  if fp == nil then return nil end

  local data = fp:read("*line")
  if data ~= "P6" then return nil end

  repeat
    data = fp:read("*line")
  until string.find(data, "#") == nil

  local image = {}
  local size_x, size_y

  size_x = string.match(data, "%d+")
  size_y = string.match(data, "%s%d+")

  data = fp:read("*line")
  if tonumber(data) ~= 255 then return nil end

  for i = 1, size_y do
    image[i] = {}
  end

  for j = 1, size_y do
    for i = 1, size_x do
      image[j][i] = { string.byte(fp:read(1)), string.byte(fp:read(1)), string.byte(fp:read(1)) }
    end
  end

  fp:close()

  return size_x, size_y, image
end

local function Get_Color_Code(img, i, j)
  local r = img[j][i][1]
  local g = img[j][i][2]
  local b = img[j][i][3]

  local code = r .. ";" .. g .. ";" .. b

  return code .. "m"
end

local function Get_Image_Rescaling(Img_Path)
  local win_spec = vim.api.nvim_list_uis()[1]
  local term_width = math.floor(win_spec["width"] * Config.term_width_percentage)
  local term_height = math.floor(win_spec["height"] * Config.term_height_percentage)
  --  because our term window is a % of the original window's height

  local handle = io.popen("identify -ping -format '%w %h' " .. Img_Path)

  if handle == nil then
    return "could not display image"
  end

  local dims_str = handle:read("*a")
  local dims = utils.Split(dims_str, " ")
  local img_ratio = tonumber(dims[1]) / tonumber(dims[2])

  local ascii_width = 2 * img_ratio * term_height
  local ascii_height = math.floor(term_height / 0.95)

  if ascii_width > term_width then
    ascii_width = term_width
    ascii_height = 0.5 * ascii_width / img_ratio
  end
  --[[
  if ascii_height > term_height then
    ascii_width = term_width
    ascii_height = term_height
  end
 ]]
  return ascii_width, ascii_height
end

function M.Create_Tmp(Img_Path)
  vim.cmd("silent !touch tmp.txt")

  local ascii_width, ascii_height = Get_Image_Rescaling(Img_Path)
  vim.cmd("silent !convert -resize " .. 2 * ascii_width .. "x" .. 4 * ascii_height .. "\\! " .. Img_Path .. " tmp.ppm")

  local ppm_w, ppm_h, img = Read_PPM("tmp.ppm")
  local width_step = 2
  local height_step = 4

  if img == nil then
    return "could not display image."
  end

  for j = 1, ppm_h, height_step do
    local line = ""
    for i = 1, ppm_w, width_step do
      line = line .. StartSet .. Get_Color_Code(img, i, j) .. "⣿" .. EndSet
    end

    local f_line = string.format("%s", line)
    vim.cmd("silent !echo -e \"" .. f_line .. "\" >> tmp.txt")
  end

  vim.cmd("silent !rm tmp.ppm")
end

return M
