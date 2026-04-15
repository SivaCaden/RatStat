local M = {}

local components = require('ratstat.components')
local git        = require('ratstat.git')
local timer      = require('ratstat.timer')
local donki      = require('ratstat.donki')
local colors     = require('ratstat.colors')

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

  colors.setup()

  vim.api.nvim_create_autocmd('ColorScheme', {
    group    = group,
    callback = function() colors.setup() end,
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
    .. "%{v:lua.require('ratstat').render()}"
    .. hl_end
end

function M.render()
  if not _config then return '' end

  local sep       = _config.separator
  local time_s    = components.time(_config.time_format)
  local warn_s    = M.part_warnings()
  local branch_s  = components.git_branch(_config.branch_prefix, git.get_branch())
  local file_s    = components.filename()
  local lsp_s     = components.lsp_clients(_config.lsp_separator)
  local percent_s = components.percent()

  -- Build plain center parts for accurate width measurement
  local center_parts = {}
  if branch_s ~= '' then center_parts[#center_parts + 1] = branch_s end
  center_parts[#center_parts + 1] = file_s
  if lsp_s ~= '' then center_parts[#center_parts + 1] = lsp_s end

  local left_plain   = time_s .. warn_s
  local center_plain = table.concat(center_parts, sep)
  local right_plain  = percent_s

  local total = vim.o.columns
  local lw    = vim.fn.strdisplaywidth(left_plain)
  local cw    = vim.fn.strdisplaywidth(center_plain)
  local rw    = vim.fn.strdisplaywidth(right_plain)
  local lpad  = math.max(0, math.floor((total - cw) / 2) - lw)
  local rpad  = math.max(0, total - lw - lpad - cw - rw)

  -- Assemble with colors (fixed slots: time=1, warn=2, branch=3, file=4, lsp=5, percent=6)
  local left_col = colors.wrap(1, time_s) .. colors.wrap(2, warn_s)

  local colored_center = {}
  if branch_s ~= '' then colored_center[#colored_center + 1] = colors.wrap(3, branch_s) end
  colored_center[#colored_center + 1] = colors.wrap(4, file_s)
  if lsp_s ~= '' then colored_center[#colored_center + 1] = colors.wrap(5, lsp_s) end
  local center_col = table.concat(colored_center, sep)

  local right_col = colors.wrap(6, percent_s)

  return left_col .. string.rep(' ', lpad) .. center_col .. string.rep(' ', rpad) .. right_col
end

function M.part_warnings()
  if not _config then return '' end
  local active = donki.get_active()
  if #active == 0 then return '' end
  return table.concat(active, ' ')
end

return M
