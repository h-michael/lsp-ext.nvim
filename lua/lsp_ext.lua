local vim = vim or {}
local util = require'lsp_ext/util'
local autocmd = require'lsp_ext/autocmd'
local callbacks = require'lsp_ext/callbacks'
local M = {
  util = util,
  callbacks = callbacks,
  set_signature_help_autocmd = autocmd.set_signature_help_autocmd,
  unset_signature_help_autocmd = autocmd.unset_signature_help_autocmd,
  set_publish_diagnostics_autocmd = autocmd.set_publish_diagnostics_autocmd,
  unset_publish_diagnostics_autocmd = autocmd.unset_publish_diagnostics_autocmd,
  _on_cursor_moved_for_signature_help = autocmd._on_cursor_moved_for_signature_help,
  _on_cursor_moved_for_publish_diagnostics = autocmd._on_cursor_moved_for_publish_diagnostics
}

vim.g["lsp_publish_diagnostics_virtualtext"] = vim.g["lsp_publish_diagnostics_virtualtext"] or true
vim.g["lsp_publish_diagnostics_display_method"] = vim.g["lsp_publish_diagnostics_display_method"] or "float"
vim.g["lsp_publish_diagnostics_severity_string_error"] = vim.g["lsp_publish_diagnostics_severity_string_error"] or "E"
vim.g["lsp_publish_diagnostics_severity_string_warning"] = vim.g["lsp_publish_diagnostics_severity_string_warning"] or "W"
vim.g["lsp_publish_diagnostics_severity_string_info"] = vim.g["lsp_publish_diagnostics_severity_string_info"] or "I"
vim.g["lsp_publish_diagnostics_severity_string_hint"] = vim.g["lsp_publish_diagnostics_severity_string_hint"] or "H"

return M
