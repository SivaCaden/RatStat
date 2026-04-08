local M = {}

local components = require('ratstat.components')
local git        = require('ratstat.git')
local timer      = require('ratstat.timer')
local donki      = require('ratstat.donki')

local _config       = nil
local _donki_timer  = nil

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
    callback = function()
      timer.stop()
      if _donki_timer then
        _donki_timer:stop()
        _donki_timer:close()
        _donki_timer = nil
      end
    end,
  })

  timer.start(1000, function()
    vim.cmd('redrawstatus')
  end)

  local api_key = os.getenv('NASA_DONKI_API_KEY')
  if api_key and api_key ~= '' then
    donki.poll(api_key)
    _donki_timer = vim.uv.new_timer()
    _donki_timer:start(60000, 60000, vim.schedule_wrap(function()
      donki.poll(api_key)
    end))
  end

  vim.api.nvim_create_user_command('Rat', function(opts)
    if opts.args == '-s' then
      donki.suppress()
    end
  end, { nargs = 1, desc = 'RatStat commands (-s: suppress space weather warnings for today)' })

  local hl_start = _config.highlight and ('%#' .. _config.highlight .. '#') or ''
  local hl_end   = _config.highlight and '%##' or ''
  vim.o.statusline = hl_start
    .. "%{v:lua.require('ratstat').part_left()}"
    .. '%='
    .. "%{v:lua.require('ratstat').part_center()}"
    .. '%='
    .. "%{v:lua.require('ratstat').part_right()}"
    .. hl_end
end

function M.part_left()
  if not _config then return '' end
  local left = components.time(_config.time_format)
  local active = donki.get_active()
  if #active > 0 then
    left = left .. _config.separator .. table.concat(active, _config.separator)
  end
  return left
end

function M.part_center()
  if not _config then return '' end
  local sep   = _config.separator
  local parts = {}
  local branch_str = components.git_branch(_config.branch_prefix, git.get_branch())
  if branch_str ~= '' then parts[#parts + 1] = branch_str end
  parts[#parts + 1] = components.filename()
  local lsp_str = components.lsp_clients(_config.lsp_separator)
  if lsp_str ~= '' then parts[#parts + 1] = lsp_str end
  return table.concat(parts, sep)
end

function M.part_right()
  if not _config then return '' end
  return components.percent()
end

return M
