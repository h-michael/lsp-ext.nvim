local vim = vim
local api = vim.api
local lsp = vim.lsp
local uv = vim.loop
local callbacks = require'lsp_contrib/callbacks'
local util = require'lsp_contrib/util'
local putil = require'lsp_contrib/private/util'

local M = {
  signature_help_debounce_timer = nil;
  diagnostics_debounce_timer = nil;
  diagnostics = vim.empty_dict();
}

function M.set_signature_help_autocmd(wait)
  wait = wait or 500
  lsp.callbacks['textDocument/signatureHelp'] = callbacks.signature_help
  api.nvim_command('augroup nvim_lsp_signature_help')
  api.nvim_command('autocmd!')
  api.nvim_command(string.format("autocmd CursorMoved,CursorMovedI * lua require'lsp_contrib.autocmd'._on_cursor_moved_for_signature_help(%s)", wait))
  api.nvim_command('augroup END')
end

function M.unset_signature_help_autocmd()
  api.nvim_command('augroup nvim_lsp_signature_help')
  api.nvim_command('autocmd!')
  api.nvim_command('augroup END')
end

function M._on_cursor_moved_for_signature_help(wait)
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

  if M.signature_help_debounce_timer ~= nil then
    if uv.is_active(M.signature_help_debounce_timer) then
      putil.clear_timeout(M.signature_help_debounce_timer)
    end
    M.signature_help_debounce_timer = nil
  end
  M.signature_help_debounce_timer = putil.set_timeout(wait, vim.schedule_wrap(lsp.buf.signature_help))
end

function M.set_publish_diagnostics_autocmd(wait)
  wait = wait or 500
  lsp.callbacks['textDocument/publishDiagnostics'] = callbacks.publish_diagnostics
  api.nvim_command('augroup nvim_lsp_publish_diagnostics')
  api.nvim_command('autocmd!')
  api.nvim_command(string.format("autocmd CursorMoved * lua require'lsp_contrib.autocmd'._on_cursor_moved_for_publish_diagnostics(%s)", wait))
  api.nvim_command('augroup END')
end

function M.unset_publish_diagnostics_autocmd()
  api.nvim_command('augroup nvim_lsp_signature_help')
  api.nvim_command('autocmd!')
  api.nvim_command('augroup END')
end

function M.set_diagnostics(diagnostics_params)
  if vim.tbl_isempty(diagnostics_params.diagnostics) then
    M.diagnostics[diagnostics_params.uri] = nil
    return
  end

  M.diagnostics[diagnostics_params.uri] = diagnostics_params.diagnostics
end

function M._on_cursor_moved_for_publish_diagnostics(wait)
  vim.validate{wait={wait,'n'}}

  local function _build_diagnostics_messages(diagnostics)
    local messages = {}
    for _, diagnostic in ipairs(diagnostics) do
      table.insert(messages, diagnostic.message)
    end

    return messages
  end

  local function _echo_diagnostic_messages()
    local current_fname = vim.uri_from_bufnr(vim.fn.bufnr)

    local diagnostics = M.diagnostics[current_fname]

    if not diagnostics then return end

    local line = vim.api.nvim_win_get_cursor(0)[0]
    local target_diagnostics = {}

    for _, diagnostic in ipairs(diagnostics) do
      if putil.is_line_in_range(diagnostic.range, line) then
        table.insert(target_diagnostics, diagnostic)
      end
    end

    if vim.tbl_isempty(target_diagnostics) then return end

    local messages = _build_diagnostics_messages(target_diagnostics)
    local echo_message = ""

    for _, message in ipairs(messages) do
      if echo_message ~= "" then echo_message = echo_message.."\n" end
      echo_message = echo_message..message
    end
    vim.api.nvim_command("echo '"..echo_message.."'")
  end

  local function _show_publish_diagnostics_floating_window()
    local function _open_floating_window(contents)
      local width
      local height = #contents
      width = 0
      for i, line in ipairs(contents) do
        -- Clean up the input and add left pad.
        line = " "..line:gsub("\r", "")
        local line_width = vim.fn.strdisplaywidth(line)
        width = math.max(line_width, width)
        contents[i] = line
      end
      -- Add right padding of 1 each.
      width = width + 1

      local floating_bufnr = vim.api.nvim_create_buf(false, true)
      local float_option = lsp.util.make_floating_popup_options(width, height)
      local floating_winnr = vim.api.nvim_open_win(floating_bufnr, false, float_option)
      vim.api.nvim_buf_set_lines(floating_bufnr, 0, -1, true, contents)
      vim.api.nvim_buf_set_option(floating_bufnr, 'modifiable', false)
      vim.api.nvim_command("autocmd CursorMoved,BufHidden,InsertCharPre <buffer> ++once lua pcall(vim.api.nvim_win_close, "..floating_winnr..", true)")
      return floating_bufnr, floating_winnr
    end

    local current_fname = vim.uri_from_bufnr(vim.fn.bufnr)

    local diagnostics = M.diagnostics[current_fname]

    if not diagnostics then return end

    local pos = vim.api.nvim_win_get_cursor(0)
    local target_diagnostics = {}

    for _, diagnostic in ipairs(diagnostics) do
      if putil.is_possition_in_range(diagnostic.range, pos) then
        table.insert(target_diagnostics, diagnostic)
      end
    end

    if vim.tbl_isempty(target_diagnostics) then return end

    local messages = _build_diagnostics_messages(target_diagnostics)

    _open_floating_window(messages)
  end

  if not (vim.g["lsp_publish_diagnostics_display_method"] == "echo") then
    _echo_diagnostic_messages()
  elseif vim.g["lsp_publish_diagnostics_display_method"] == "float" then
    if M.diagnostics_debounce_timer ~= nil then
      if uv.is_active(M.diagnostics_debounce_timer) then
        putil.clear_timeout(M.diagnostics_debounce_timer)
      end
      M.diagnostics_debounce_timer = nil
    end
    M.diagnostics_debounce_timer = putil.set_timeout(wait, vim.schedule_wrap(_show_publish_diagnostics_floating_window))
  end
end

return M
