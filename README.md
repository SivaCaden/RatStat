# RatStat

A statusline plugin for Neovim.

Displays, left to right: **current time · git branch · filename · active LSP · cursor position %**

## Requirements

Neovim 0.10+

## Installation

### lazy.nvim

The recommended approach is to keep each plugin's spec in its own file under `lua/plugins/`.

**`~/.config/nvim/lua/plugins/ratstat.lua`:**
```lua
return {
  'SivaCaden/RatStat',
  opts = {},
}
```

Lazy will automatically call `setup(opts)` when `opts` is present. To pass custom options:

```lua
return {
  'SivaCaden/RatStat',
  opts = {
    separator     = '  ',
    time_format   = '%I:%M %p',
    branch_prefix = ' ',
  },
}
```

Make sure your **`~/.config/nvim/init.lua`** is set up to scan that directory:

```lua
require('lazy').setup('plugins')
```

## Configuration

All options are optional — calling `setup()` with no arguments uses the defaults.

```lua
require('ratstat').setup({
  separator     = '  ',       -- string inserted between each component
  time_format   = '%H:%M:%S', -- passed to os.date()
  branch_prefix = ' ',       -- prepended to the git branch name
  lsp_separator = ', ',       -- joins multiple LSP client names
  highlight     = nil,        -- highlight group name, e.g. 'StatusLine'
})
```
