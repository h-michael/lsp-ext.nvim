local vim = vim or {}
local api = vim.api
local lsp = vim.lsp

local M = {}

function M.signature_help(_, method, result)
  if not (result and result.signatures and result.signatures[1]) then
    return nil
  end
  local lines = lsp.util.convert_signature_help_to_markdown_lines(result)
  lines = lsp.util.trim_empty_lines(lines)
  if lines == nil or vim.tbl_isempty(lines) then
    return nil
  end
  lsp.util.focusable_preview(method, function()
    return lines, lsp.util.try_trim_markdown_code_blocks(lines)
  end)
end

function M.publish_diagnostics(_, _, result)
  if not result then return end
  local uri = result.uri
  local bufnr = vim.uri_to_bufnr(uri)
  require'lsp_ext/autocmd'.set_diagnostics(result)
  lsp.util.buf_clear_diagnostics(bufnr)
  lsp.util.buf_diagnostics_save_positions(bufnr, result.diagnostics)
  lsp.util.buf_diagnostics_underline(bufnr, result.diagnostics)
  lsp.util.buf_diagnostics_signs(bufnr, result.diagnostics)
  if vim.g["lsp_publish_diagnostics_virtualtext"] then
    lsp.util.buf_diagnostics_virtual_text(bufnr, result.diagnostics)
  end
  api.nvim_command("doautocmd User LspDiagnosticsChanged")
end

return M
