<div align="center">

# Hooks
<sub>**Blazingly fast file management for Neovim.**</sub>

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
local ui = require('hooks.ui')
vim.keymap.set({ 'n', 'v' }, '<leader>a', require('hooks.marks').add_file, { desc = '[A]dd hook' })
vim.keymap.set({ 'n', 'v' }, '<leader>e', ui.toggle_menu, { desc = 'Toggle hook menu' })
vim.keymap.set({ 'n', 'v' }, '<leader>1', function() ui.nav_file(1) end, { desc = 'Go to hook [1]' })
vim.keymap.set({ 'n', 'v' }, '<leader>2', function() ui.nav_file(2) end, { desc = 'Go to hook [2]' })
vim.keymap.set({ 'n', 'v' }, '<leader>3', function() ui.nav_file(3) end, { desc = 'Go to hook [3]' })
vim.keymap.set({ 'n', 'v' }, '<leader>4', function() ui.nav_file(4) end, { desc = 'Go to hook [4]' })
```

## Modules
- `hooks`
- `hooks.ui`
- `hooks.marks`
- `hooks.utils`
