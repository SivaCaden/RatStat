# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

RatStat is a statusline plugin for Neovim, written in Lua.

## Neovim Plugin Conventions

- Plugin entry point should live at `lua/ratstat/init.lua`
- Follow the standard Neovim plugin directory layout: `lua/`, `plugin/`, `doc/`
- The `plugin/` directory contains auto-loaded Vimscript/Lua (runs on startup); `lua/` contains modules loaded on demand via `require`
- Use `vim.api`, `vim.fn`, and `vim.opt` for Neovim API calls rather than Vimscript interop where possible

## Testing

Neovim Lua plugins are typically tested with [plenary.nvim](https://github.com/nvim-lua/plenary.nvim) or [neotest](https://github.com/nvim-neotest/neotest). Tests live in `tests/` and can be run headlessly:

```bash
nvim --headless -u tests/minimal_init.lua -c "PlenaryBustedDirectory tests/ {minimal_init = 'tests/minimal_init.lua'}"
```

## Lua Style

- Use `local` for all variables and functions unless intentionally exposing a module API
- Return a module table from each `lua/` file rather than using globals
- Format with `stylua` if available (`stylua lua/`)
