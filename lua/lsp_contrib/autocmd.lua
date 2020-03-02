local vim = vim
local api = vim.api
local lsp = vim.lsp
local uv = vim.loop
local util = require'lsp_contrib/util'
local putil = require'lsp_contrib/private/util'

local M = {
  debounce_timer = nil
}

function M.set_signature_help_autocmd(wait)
  wait = wait or 500
  api.nvim_command('augroup nvim_lsp_signature_help')
  api.nvim_command('autocmd!')
  api.nvim_command(string.format("autocmd CursorMoved,CursorMovedI * lua require'nvim_lsp_contrib'.autocmd._on_cursor_moved(%s)", wait))
  api.nvim_command('augroup END')
end

function M.unset_signature_help_autocmd()
  api.nvim_command('augroup nvim_lsp_signature_help')
  api.nvim_command('autocmd!')
  api.nvim_command('augroup END')
end

function M._on_cursor_moved(wait)
  vim.validate{wait={wait,'n'}}

  local function should_call_signature_help()
    local chars = vim.tbl_flatten(vim.tbl_map(function(cap)
        return cap.resolved_capabilities.signature_help_trigger_characters
      end, util.buf_resolved_capabilities()))
    if vim.tbl_contains(chars, putil.get_before_char_skip_white()) then
      return true
    end
    return false
  end

  if not should_call_signature_help() then return end

  if M.debounce_timer ~= nil then
    if uv.is_active(M.debounce_timer) then
      putil.clear_timeout(M.debounce_timer)
    end
    M.debounce_timer = nil
  end
  M.debounce_timer = putil.set_timeout(wait, vim.schedule_wrap(lsp.buf.signature_help))
end

return M
