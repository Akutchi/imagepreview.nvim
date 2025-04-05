# ImagePreview

## Description

In all that follows, I am supposing that you're also using LunarVim with the LazyVim plugin manager.\
Installation procedures might vary depending on your architecture.

ImagePreview is a simple program that display preview of images in a lunarvim environnement.
If you're like me and you don't want to use Xterm, Kitty etc. (for whatever reason), you
can't really preview full blown images in your basic terminal.\
This is why I decided to create a program that could display ascii rendering of images.
As such, I'm fully conscious of the fact that it is what it is. The resolution depending
largely on the original image's details.

## Usage

Its usage is pretty basic. First, open the tree explorer with <leader>e, and place the cursor on
the image you want to preview. Then, use <leader>ip to preview your image. Clicking anywhere else
the ascii rendering close the preview.

## Installation

To use ImagePreview, you will need several dependencies.\
- First, you will need [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter),
which you can get for example with snap (see TheZoraiz repo for other way of installation).
- Then, you'll also need the nui.vim plugin. Please add it in your config.lua file :
```lua
{ "MunifTanjim/nui.nvim" }
```
- Finally, and in order to create the key binding, copy/paste this in your config.lua file :
```lua
lvim.builtin.which_key.mappings["i"] = {
  name = "Image",
  p = { "<cmd>lua require('imagepreview').Preview()<cr>", "Preview an image" }
}
```
