local M = {}

local _cache = {}

local function read_head(git_dir)
  local path = git_dir .. '/HEAD'
  local f = io.open(path, 'r')
  if not f then return '' end
  local line = f:read('*l')
  f:close()
  if not line then return '' end
  local branch = line:match('^ref: refs/heads/(.+)$')
  return branch or line:sub(1, 7)
end

local function find_git_dir(filepath)
  local dir = vim.fn.fnamemodify(filepath, ':p:h')
  while dir ~= '/' do
    local git = dir .. '/.git'
    local stat = vim.uv.fs_stat(git)
    if stat then
      if stat.type == 'directory' then
        return git
      elseif stat.type == 'file' then
        local f = io.open(git, 'r')
        if f then
          local line = f:read('*l')
          f:close()
          local linked = line and line:match('^gitdir: (.+)$')
          if linked then
            if linked:sub(1, 1) == '/' then
              return linked
            else
              return dir .. '/' .. linked
            end
          end
        end
      end
    end
    local parent = vim.fn.fnamemodify(dir, ':h')
    if parent == dir then break end
    dir = parent
  end
  return nil
end

function M.get_branch()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == '' then return '' end
  local git_dir = find_git_dir(filepath)
  if not git_dir then return '' end
  if _cache[git_dir] == nil then
    _cache[git_dir] = read_head(git_dir)
  end
  return _cache[git_dir]
end

function M.invalidate()
  local filepath = vim.api.nvim_buf_get_name(0)
  if filepath == '' then return end
  local git_dir = find_git_dir(filepath)
  if git_dir then
    _cache[git_dir] = nil
  end
end

function M.reset()
  _cache = {}
end

return M
