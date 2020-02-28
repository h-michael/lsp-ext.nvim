local vim = vim
local lsp = vim.lsp
local inspect = vim.inspect
local uv = vim.loop

local M = {}

function M.pp(...)
  print(inspect(...))
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

return M
