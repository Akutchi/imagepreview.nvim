local utils = require("imagepreview.utils")

local Console_Setup_Path = "/etc/default/console-setup"

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


-- Get FONTFACE="[FONTNAME-TYPE]"
local handle = io.popen("cat " .. Console_Setup_Path .. " | grep FONTFACE")

if handle == nil then
  M.base_font = ""
else
  local raw = handle:read("*a")
  local raw_fontname = utils.Split(raw, "=")[2]
  local font_clean = string.sub(raw_fontname, 2, #raw_fontname - 1)
  local font_without_type = utils.Split(font_clean, "-")[1]

  M.base_font = font_without_type
end

return M
