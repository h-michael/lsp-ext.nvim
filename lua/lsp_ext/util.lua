local vim = vim or {}
local api = vim.api
local lsp = vim.lsp
local putil = require'lsp_ext/private/util'

local M = {}

function M.pp_buf_clients()
  putil.pp(lsp.buf_get_clients())
end

function M.buf_clients_config()
  return putil.map_clients(function(client)
    return { name = client.name, filetype = client.filetype, config = client.config }
  end)
end

function M.pp_buf_clients_config()
  putil.pp(M.buf_clients_config())
end

function M.buf_servers_capabilities()
  return putil.map_clients(function(client)
    return { name = client.name, filetype = client.filetype, server_capabilities = client.server_capabilities }
  end)
end

function M.pp_buf_servers_capabilities()
  putil.pp(M.buf_servers_capabilities())
end

function M.buf_resolved_capabilities()
  return putil.map_clients(function(client)
    return { name = client.name, filetype = client.filetype, resolved_capabilities = client.resolved_capabilities }
  end)
end

function M.pp_buf_resolved_capabilities()
  putil.pp(M.buf_resolved_capabilities())
end

function M.set_default_diagnostics_highlight()
  local underline_highlight_name = "LspDiagnosticsUnderline"
  vim.cmd(string.format("highlight default %s gui=underline cterm=underline", underline_highlight_name))
  for kind, _ in pairs(lsp.protocol.DiagnosticSeverity) do
    if type(kind) == 'string' then
      vim.cmd(string.format("highlight default link %s%s %s", underline_highlight_name, kind, underline_highlight_name))
    end
  end

  local default_severity_highlight = {
    [lsp.protocol.DiagnosticSeverity.Error] = { guifg = "Red" };
    [lsp.protocol.DiagnosticSeverity.Warning] = { guifg = "Orange" };
    [lsp.protocol.DiagnosticSeverity.Information] = { guifg = "LightBlue" };
    [lsp.protocol.DiagnosticSeverity.Hint] = { guifg = "LightGrey" };
  }

  -- Initialize default severity highlights
  for severity, hi_info in pairs(default_severity_highlight) do
    local severity_name = lsp.protocol.DiagnosticSeverity[severity]
    local highlight_name = "LspDiagnostics"..severity_name
    -- Try to fill in the foreground color with a sane default.
    local cmd_parts = {"highlight", "default", highlight_name}
    for k, v in pairs(hi_info) do
      table.insert(cmd_parts, k.."="..v)
    end
    api.nvim_command(table.concat(cmd_parts, ' '))
  end
end

return M
