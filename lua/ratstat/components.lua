local M = {}

function M.time(fmt)
  return os.date(fmt)
end

function M.git_branch(prefix, cached_branch)
  if not cached_branch or cached_branch == '' then return '' end
  return prefix .. cached_branch
end

function M.filename()
  local name = vim.fn.expand('%:t')
  if name == '' then return '[No Name]' end
  if vim.bo.modified then name = name .. ' [+]' end
  if vim.bo.readonly then name = name .. ' [-]' end
  return name
end

function M.lsp_clients(sep)
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return '' end
  local names = {}
  for _, c in ipairs(clients) do
    names[#names + 1] = c.name
  end
  return table.concat(names, sep)
end

function M.percent()
  local cur = vim.fn.line('.')
  local last = vim.fn.line('$')
  if last == 0 then return '0%' end
  return math.floor(cur / last * 100) .. '%'
end

return M
