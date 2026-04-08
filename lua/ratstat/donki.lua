local M = {}

local _state         = { flr = false, cme = false }
local _suppress_date = nil

-- Parses a DONKI timestamp ("YYYY-MM-DDTHH:MMZ") into a Unix timestamp.
-- Treats parsed values as local time; DONKI returns UTC, but the delta is
-- acceptable given that flares last minutes-to-hours and CMEs last days.
local function parse_timestamp(s)
  if not s then return nil end
  local y, mo, d, h, mi = s:match('(%d%d%d%d)-(%d%d)-(%d%d)T(%d%d):(%d%d)')
  if not y then return nil end
  return os.time({
    year  = tonumber(y),
    month = tonumber(mo),
    day   = tonumber(d),
    hour  = tonumber(h),
    min   = tonumber(mi),
    sec   = 0,
  })
end

-- Determines if a flare event is currently active.
-- A flare is active if its beginTime has passed AND either
-- endTime is nil (still ongoing) OR endTime is in the future.
local function is_flr_active(flr)
  local begin_t = parse_timestamp(flr.beginTime)
  if not begin_t then return false end
  local now = os.time()
  if begin_t > now then return false end
  if not flr.endTime then return true end
  local end_t = parse_timestamp(flr.endTime)
  return end_t ~= nil and end_t > now
end

-- Determines if a CME (coronal mass ejection) is currently active.
-- CMEs don't have an endTime field. A CME is active if its startTime
-- was within the last 3 days.
local function is_cme_active(cme)
  local start_t = parse_timestamp(cme.startTime)
  if not start_t then return false end
  return (os.time() - start_t) <= (3 * 86400)
end

local function today()
  return os.date('%Y-%m-%d')
end

function M.poll(api_key)
  local end_date   = today()
  local start_date = os.date('%Y-%m-%d', os.time() - 2 * 86400)
  local base       = 'https://api.nasa.gov/DONKI/'
  local params     = '?startDate=' .. start_date .. '&endDate=' .. end_date .. '&api_key=' .. api_key

  vim.system({ 'curl', '-sf', base .. 'FLR' .. params }, { text = true }, function(result)
    if result.code ~= 0 then return end
    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok or type(data) ~= 'table' then return end
    local active = false
    for _, flr in ipairs(data) do
      if is_flr_active(flr) then active = true; break end
    end
    _state.flr = active
  end)

  vim.system({ 'curl', '-sf', base .. 'CME' .. params }, { text = true }, function(result)
    if result.code ~= 0 then return end
    local ok, data = pcall(vim.json.decode, result.stdout)
    if not ok or type(data) ~= 'table' then return end
    local active = false
    for _, cme in ipairs(data) do
      if is_cme_active(cme) then active = true; break end
    end
    _state.cme = active
  end)
end

function M.get_active()
  if _suppress_date == today() then return {} end
  local labels = {}
  if _state.flr then labels[#labels + 1] = ' 󰖙 FLR' end
  if _state.cme then labels[#labels + 1] = ' 󰖙 CME' end
  return labels
end

function M.suppress()
  _suppress_date = today()
end

-- Test helpers
M._parse_timestamp   = parse_timestamp
M._is_flr_active     = is_flr_active
M._is_cme_active     = is_cme_active
M._reset             = function() _state = { flr = false, cme = false }; _suppress_date = nil end
M._set_state         = function(s) _state = s end
M._set_suppress_date = function(d) _suppress_date = d end

return M
