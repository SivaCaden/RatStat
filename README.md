# RatStat

A statusline plugin for Neovim.

Displays, left to right: **current time · git branch · filename · active LSP · cursor position %**

## Requirements

- Neovim 0.10+
- A [Nerd Font](https://www.nerdfonts.com/) — required for space weather warning icons (CME, solar flare). Without one, the icons will not render correctly.

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

## Colors

RatStat automatically pulls foreground colors from your active colorscheme — no manual configuration needed.

On startup (and on every `ColorScheme` event), it reads the `fg` from these highlight groups in order:

```
Function  String  Keyword  Type  Constant  Special  Statement  Identifier
```

Each group that defines a foreground color becomes a `RatStatN` highlight group (e.g. `RatStat1`, `RatStat2`, …), all sharing the `StatusLine` background. The statusline components are then assigned colors by cycling through whatever was found:

| Slot | Component |
|------|-----------|
| 1 | Time |
| 2 | Space weather warnings |
| 3 | Git branch |
| 4 | Filename |
| 5 | LSP clients |
| 6 | Cursor % |

If your colorscheme defines fewer than 6 of those highlight groups, slots wrap around. If none are found (e.g. a very minimal colorscheme), components render in the default `StatusLine` color with no cycling.

You can override any `RatStatN` group after calling `setup()`:

```lua
vim.api.nvim_set_hl(0, 'RatStat1', { fg = '#ff8800', bg = '#1e1e2e' })
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
