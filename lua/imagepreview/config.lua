local utils = require("imagepreview.utils")

local Console_Setup_Path = "/etc/default/console-setup"
local Font = { Family = "-", Size = "x" }

M = {
  UI_target_width = 476,
  UI_target_height = 111,
  term_width_percentage = 0.30,
  term_height_percentage = 0.95
}
-- Throughout init/braille.lua I am using those precalculated target values. Why ?
-- And what are they ?
--
-- To understand this, let us first understand terminals. In Unix (at least) each
-- char has a definite bounding box. To show our preview, we thus want to sample our
-- original image and show a densly packable char that we can then colorize.
-- The denser char there exist and that I know of is the braille-8 character (" ⣿ ")
-- (courtesy of TheZoraiz for this).
-- Not only is this char the denser (it fills the most place out of the bounding box),
-- but it is also packable, meaning that there is little to no space in between
-- repetitions; as can be seen below.
-- ⣿⣿⣿⣿⣿
-- ⣿⣿⣿⣿⣿
--
-- But there soon arise a limitation. Because a terminal can only colorize a character
-- in its entierty, we can't colorize a portion of it, limiting the image resolution.
-- We could get away with it if I could scale my preview up. But in a neovim environnement,
-- as with every terminal, we are limited to the screen size. Thus, the only way I found
-- to scale up was to scale down the terminal font at the same time, allowing me to pack
-- more char in the same space.
--
-- However, doing the scaling in the Preview method led to nothing. This is because, neovim
-- don't have the time to update the environnement's variables before we create our preview
-- window. As such, doing so create a window in a scaled down environnment, but with sizes
-- calculated as if the UI sizes hadn't changed. Hence, by precalculating the final
-- environnement's (width, height) we can scale when we want and still have a correct preview.
--
-- The UI target width/height are recuperated from nvim_list_uis()[0] after having applied a
-- $ gsettings set org.gnome.desktop.interface monospace-font-name 'Ubuntu Mono 6' scaling.

-- This function get a string XXX="[YYY][opt][ZZZ]" and get
-- opt = Family => [YYY]
-- opt = Size => [ZZZ]
--
-- This is based on the console-setup file.
local function Get_Font_Option(handle, opt)
  local raw = handle:read("*a")
  local raw_font_opt = utils.Split(raw, "=")[2]
  local font_opt_no_str = string.sub(raw_font_opt, 2, #raw_font_opt - 2)
  local font_opt_clean = utils.Split(font_opt_no_str, opt)

  if opt == Font.Family then
    return font_opt_clean[1]
  elseif opt == Font.Size then
    return font_opt_clean[2]
  end
end

local function Get_Font()
  -- Get FONTFACE="[FONTNAME]-[TYPE]"
  local handle = io.popen("cat " .. Console_Setup_Path .. " | grep FONTFACE")

  -- Get FONTSIZE="8x[SIZE]"
  local handle2 = io.popen("cat " .. Console_Setup_Path .. " | grep FONTSIZE")

  if handle == nil or handle2 == nil then
    M.base_font = ""
  else
    return { font_family = Get_Font_Option(handle, Font.Family), font_size = Get_Font_Option(handle2, Font.Size) }
  end
end

M.base_font = Get_Font()

return M
