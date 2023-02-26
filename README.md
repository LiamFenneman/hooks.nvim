<div align="center">

# Hooks
<sub>**Blazingly fast file navigation for Neovim.**</sub>

[![harpoon](https://img.shields.io/static/v1?label=Based%20on&message=harpoon&color=blueviolet&style=for-the-badge)](https://github.com/ThePrimeagen/harpoon)
[![Lua](https://img.shields.io/badge/Lua-blue.svg?style=for-the-badge&logo=lua)](http://www.lua.org)
[![Neovim](https://img.shields.io/badge/Neovim%200.8+-green.svg?style=for-the-badge&logo=neovim)](https://neovim.io)

</div>

## Use Case

A common scenario when editing projects is working on multiple files at the same time. Many solutions exist for this problem such as using tabs, fuzzy finders, `:bnext`/`:bprev`. None are as fast as having each file as its own keybind.

With **hooks** you add files to a hook list. Keybinds can be setup to navigate to a certain index within the list.

Managing your list is easy with the hooks menu. Since the menu is just a buffer, all the same motions can be used to modify or delete any file.

## Installation
Using [packer](https://github.com/wbthomason/packer.nvim):
```lua
use {
    'LiamFenneman/hooks.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
}
```

## Quick Configuration

```lua
-- nvim/after/plugin/hooks.lua
require('hooks').setup({})
```

## Default Configuration

```lua
-- nvim/after/plugin/hooks.lua
require('hooks').setup({
    menu = {
        width = 60,
        height = 10,
        border_chars = { '─', '│', '─', '│', '╭', '╮', '╯', '╰' },
    },
    mappings = {
        add_file = '<leader>a',
        toggle_menu = '<leader>e',
        nav_file = {
            [1] = '<leader>1',
            [2] = '<leader>2',
            [3] = '<leader>3',
            [4] = '<leader>4',
        },
    },
})
```
