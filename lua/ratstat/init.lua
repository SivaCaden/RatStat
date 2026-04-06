local M = {}

local components = require('ratstat.components')
local git        = require('ratstat.git')
local timer      = require('ratstat.timer')

local _config = nil

local defaults = {
  separator     = '  ',
  time_format   = '%H:%M:%S',
  branch_prefix = ' ',
  lsp_separator = ', ',
  highlight     = nil,
}

function M.setup(user_config)
  _config = vim.tbl_deep_extend('force', defaults, user_config or {})

  git.reset()

  local group = vim.api.nvim_create_augroup('RatStat', { clear = true })

  vim.api.nvim_create_autocmd({ 'BufEnter', 'DirChanged' }, {
    group    = group,
    callback = function() git.invalidate() end,
  })

  vim.api.nvim_create_autocmd('VimLeavePre', {
    group    = group,
    callback = function() timer.stop() end,
  })

  timer.start(1000, function()
    vim.cmd('redrawstatus')
  end)

  vim.o.statusline = "%{%v:lua.require('ratstat').statusline()%}"
end

function M.statusline()
  if not _config then return '' end

  local sep   = _config.separator
  local parts = {}

  local t = components.time(_config.time_format)
  if t ~= '' then parts[#parts + 1] = t end

  local branch_str = components.git_branch(_config.branch_prefix, git.get_branch())
  if branch_str ~= '' then parts[#parts + 1] = branch_str end

  parts[#parts + 1] = components.filename()

  local lsp_str = components.lsp_clients(_config.lsp_separator)
  if lsp_str ~= '' then parts[#parts + 1] = lsp_str end

  parts[#parts + 1] = components.percent()

  local line = table.concat(parts, sep)

  if _config.highlight then
    return string.format('%%#%s#%s%%##', _config.highlight, line)
  end

  return line
end

return M
