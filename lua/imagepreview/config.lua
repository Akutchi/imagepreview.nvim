local utils = require("imagepreview.utils")

local Console_Setup_Path = "/etc/default/console-setup"

-- target values are calculated for a font rescale " Ubuntu Mono 6 "
M = { target_width = 476, target_height = 111, term_width_percentage = 0.30, term_height_percentage = 0.95 }

-- Get FONTFACE="[FONTNAME-TYPE]"
local handle = io.popen("cat " .. Console_Setup_Path .. " | grep FONTFACE")

if handle == nil then
  M.base_font = ""
end

local raw = handle:read("*a")

raw = 'FONTFACE="0xProtoNerdFont"'
local raw_fontname = utils.Split(raw, "=")[2]
local font_clean = string.sub(raw_fontname, 2, #raw_fontname - 1) -- there are " to remove
local font_without_type = utils.Split(raw_fontname, "-")[1]       -- remove -Regular etc.

M.base_font = font_clean

return M
