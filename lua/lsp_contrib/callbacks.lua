local vim = vim
local lsp = vim.lsp

local M = {}

function M.signature_help(_, method, result)
  local function convert_signature_help_to_markdown_lines(signature_help)
    if not signature_help.signatures then
      return
    end
    --The active signature. If omitted or the value lies outside the range of
    --`signatures` the value defaults to zero or is ignored if `signatures.length
    --=== 0`. Whenever possible implementors should make an active decision about
    --the active signature and shouldn't rely on a default value.
    local contents = {}
    local active_signature = signature_help.activeSignature or 0
    -- If the activeSignature is not inside the valid range, then clip it.
    if active_signature >= #signature_help.signatures then
      active_signature = 0
    end
    local signature = signature_help.signatures[active_signature + 1]
    if not signature then
      return
    end
    vim.list_extend(contents, vim.split(signature.label, '\n', true))
    if signature.documentation then
      lsp.util.convert_input_to_markdown_lines(signature.documentation, contents)
    end
    if signature_help.parameters then
      local active_parameter = signature_help.activeParameter or 0
      -- If the activeParameter is not inside the valid range, then clip it.
      if active_parameter >= #signature_help.parameters then
        active_parameter = 0
      end
      local parameter = signature.parameters and signature.parameters[active_parameter]
      if parameter then
        --[=[
        --Represents a parameter of a callable-signature. A parameter can
        --have a label and a doc-comment.
        interface ParameterInformation {
          --The label of this parameter information.
          --
          --Either a string or an inclusive start and exclusive end offsets within its containing
          --signature label. (see SignatureInformation.label). The offsets are based on a UTF-16
          --string representation as `Position` and `Range` does.
          --
          --*Note*: a label of type string should be a substring of its containing signature label.
          --Its intended use case is to highlight the parameter label part in the `SignatureInformation.label`.
          label: string | [number, number];
          --The human-readable doc-comment of this parameter. Will be shown
          --in the UI but can be omitted.
          documentation?: string | MarkupContent;
        }
        --]=]
        -- TODO highlight parameter
        if parameter.documentation then
          lsp.util.convert_input_help_to_markdown_lines(parameter.documentation, contents)
        end
      end
    end
    return contents
  end

  if not (result and result.signatures and result.signatures[1]) then
    return nil
  end
  local lines = convert_signature_help_to_markdown_lines(result)
  lines = lsp.util.trim_empty_lines(lines)
  if lines == nil or vim.tbl_isempty(lines) then
    return nil
  end
  lsp.util.focusable_preview(method, function()
    return lines, lsp.util.try_trim_markdown_code_blocks(lines)
  end)
end

function M.publish_diagnostics(_, _method, result)
  if not result then return end
  local uri = result.uri
  local bufnr = vim.uri_to_bufnr(uri)
  require'lsp_contrib/autocmd'.set_diagnostics(result)
  lsp.util.buf_clear_diagnostics(bufnr)
  lsp.util.buf_diagnostics_save_positions(bufnr, result.diagnostics)
  lsp.util.buf_diagnostics_underline(bufnr, result.diagnostics)
  lsp.util.buf_diagnostics_signs(bufnr, result.diagnostics)
  if vim.g["lsp_publish_diagnostics_virtualtext"] then
    lsp.util.buf_diagnostics_virtual_text(bufnr, result.diagnostics)
  end
  vim.api.nvim_command("doautocmd User LspDiagnosticsChanged")
end

return M
