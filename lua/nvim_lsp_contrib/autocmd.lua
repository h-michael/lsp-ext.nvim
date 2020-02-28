local vim = vim
local api = vim.api
local lsp = vim.lsp
local uv = vim.loop
local putil = require'nvim_lsp_contrib/private/util'

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

  if M.debounce_timer ~= nil then
    if uv.is_active(M.debounce_timer) then
      putil.clear_timeout(M.debounce_timer)
    end
    M.debounce_timer = nil
  end
  M.debounce_timer = putil.set_timeout(wait, vim.schedule_wrap(lsp.buf.signature_help))
end

return M
