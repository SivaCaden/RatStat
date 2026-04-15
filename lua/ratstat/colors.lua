local M = {}

local hl_sources = {
  'Function', 'String', 'Keyword', 'Type',
  'Constant', 'Special', 'Statement', 'Identifier',
}

local _count = 0

function M.setup()
  local sl = vim.api.nvim_get_hl(0, { name = 'StatusLine', link = false })
  local bg = sl.bg

  _count = 0
  for _, name in ipairs(hl_sources) do
    local hl = vim.api.nvim_get_hl(0, { name = name, link = true })
    if hl.fg then
      _count = _count + 1
      vim.api.nvim_set_hl(0, 'RatStat' .. _count, { fg = hl.fg, bg = bg })
    end
  end
end

-- Wraps text in a highlight group, cycling through available colors by index.
function M.wrap(index, text)
  if _count == 0 or text == '' then return text end
  local i = ((index - 1) % _count) + 1
  return '%#RatStat' .. i .. '#' .. text .. '%#StatusLine#'
end

return M
