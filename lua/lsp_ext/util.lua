local vim = vim or {}
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

return M
