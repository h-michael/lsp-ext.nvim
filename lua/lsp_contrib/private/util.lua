local vim = vim or {}
local api = vim.api
local lsp = vim.lsp
local inspect = vim.inspect
local uv = vim.loop

local M = {}

function M.pp(...)
  if select("#", ...) == 1 then
    api.nvim_command("echo '"..inspect(...).."'")
  else
    api.nvim_command("echo '"..inspect({...}).."'")
  end
end

function M.map_clients(func)
  local clients = lsp.buf_get_clients()
  return vim.tbl_map(func, clients)
end

function M.set_timeout(timeout, callback)
  local timer = uv.new_timer()
  local function ontimeout()
    uv.timer_stop(timer)
    uv.close(timer)
    callback(timer)
  end
  uv.timer_start(timer, timeout, 0, ontimeout)
  return timer
end

function M.clear_timeout(timer)
  uv.timer_stop(timer)
  uv.close(timer)
end

function M.set_interval(interval, callback)
  local timer = uv.new_timer()
  local function ontimeout()
    callback(timer)
  end
  uv.timer_start(timer, interval, interval, ontimeout)
  return timer
end

function M.get_before_char_skip_white()
  local function get_before_line()
    local text = vim.fn.getline('.')
    local idx = vim.fn.min({ vim.fn.strlen(text), vim.fn.col('.') - 2})
    idx = vim.fn.max({idx, -1 })
    if idx == -1 then
      return ''
    end
    return text:sub(1, idx + 1)
  end

  local current_lnum = vim.fn.line('.')

  local lnum = current_lnum
  while lnum > 0 do
    local text
    if lnum == current_lnum then
      text = get_before_line()
    else
      text = vim.fn.getline(lnum)
    end
    local match = vim.fn.matchlist(text, '\\([^[:blank:]]\\)\\s*$')

    if vim.fn.get(match, 1, nil) ~= nil then
      return match[1]
    end
    lnum = lnum - 1
  end

  return ''
end

function M.is_possition_in_range(range, _pos)
  local pos = _pos or api.nvim_win_get_cursor(0)

  local line = pos[1] - 1
  local col = pos[2]

  if range.start.line > line or range["end"].line < line then return false end

  if range.start.line == range["end"].line then
    if range.start.line == line and (range.start.character <= col and range["end"].character >=  col) then
      return true
    else
      return false
    end
  end

  if range.start.line == line then
    if range.start.character <= col then
      return true
    else
      return false
    end
  end

  if range.start.line < line and range["end"].line > line then
    return true
  end

  if range["end"].line == line then
    if range.start.character >= col then
      return true
    else
      return false
    end
  end

  return false
end

function M.is_line_in_range(range, _line)
  local line = _line or api.nvim_win_get_cursor(0)[1]
  line = line - 1

  if range.start.line > line or range["end"].line < line then return false end

  return true
end

return M
