# ImagePreview

## Description

ImagePreview is a simple program that display preview of images in a neovim environnement.
If you're like me and you don't want to use Xterm, Kitty etc. (for whatever reason), you
can't really preview full blown images in your basic terminal.\
This is why I decided to create a program that could display ascii rendering of images.
As such, I'm fully conscious of the fact that it is what it is. The resolution depending
largely on the original image's details.

## Usage

Its usage is pretty basic. First, open the tree explorer with \<leader>e, and place the cursor on
the image you want to preview. Then, use \<leader>ip to preview your image. Clicking anywhere else
the ascii rendering close the preview.

## Installation

### Requirements

- [ascii-image-converter](https://github.com/TheZoraiz/ascii-image-converter)
- Neovim >= 0.5.0
- [nui.nvim](https://github.com/MunifTanjim/nui.nvim)

### Configuration

#### [Lazy.nvim](https://github.com/folke/lazy.nvim)

```lua
{"Akutchi/ImagePreview"}
```
To create the key binding, copy/paste this in your config.lua file, or wherever your config is :
```lua
lvim.builtin.which_key.mappings["i"] = {
  name = "Image",
  p = { "<cmd>lua require('imagepreview').Preview()<cr>", "Preview an image" }
}
```

## Credits

This is my first neovim plugin. It was _hell_ to create [1], and as such, I'd like to thank some people
that helped me create my plugin (without them knowing, ofc). Those are,
- [m4xshen](https://m4xshen.dev/posts/develop-a-neovim-plugin-in-lua) for the general idea on how to create a 
local plugin.
- [D029](https://vi.stackexchange.com/a/46098) and
[Folke](https://www.reddit.com/r/neovim/comments/13rshwo/cant_get_lazynvim_to_load_local_dev_plugins_for/)
for understanding lua modules and the require function and how to add my local plugin to the lua path.
- [Gonçalo Alves](https://dev.to/iamgoncaloalves/how-i-developed-my-first-neovim-plugin-a-step-by-step-guide-1lcb)
for knowing how to locally reload my plugin using lazy.nvim.

[1] Not really the plugin in itself, but moreso the local config.
