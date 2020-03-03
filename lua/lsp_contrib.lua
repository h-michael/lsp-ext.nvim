local vim = vim or {}
local util = require'lsp_contrib/util'
local autocmd = require'lsp_contrib/autocmd'
local callbacks = require'lsp_contrib/callbacks'
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

vim.g["lsp_publish_diagnostics_virtualtext"] = false
vim.g["lsp_publish_diagnostics_display_method"] = "float"
vim.g["lsp_publish_diagnostics_severity_string_error"] = "E"
vim.g["lsp_publish_diagnostics_severity_string_warning"] = "W"
vim.g["lsp_publish_diagnostics_severity_string_info"] = "I"
vim.g["lsp_publish_diagnostics_severity_string_hint"] = "H"

return M
