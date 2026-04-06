local M = {}

local _timer = nil

function M.start(interval_ms, callback)
  if _timer then return end
  _timer = vim.uv.new_timer()
  _timer:start(0, interval_ms, vim.schedule_wrap(callback))
end

function M.stop()
  if _timer then
    _timer:stop()
    _timer:close()
    _timer = nil
  end
end

return M
