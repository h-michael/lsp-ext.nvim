local vim = vim
local lsp = vim.lsp
local util = require'nvim_lsp_contrib/internal/util'

local M = {}

function M.pp_buf_clients()
  util.pp(lsp.buf_get_clients())
end

function M.pp_buf_clients_config()
  util.pp_map_clients(function(client)
    return { name = client.name, config = client.config }
  end)
end

function M.pp_buf_servers_capabilities()
  util.pp_map_clients(function(client)
    return { name = client.name, server_capabilities = client.server_capabilities }
  end)
end

function M.pp_buf_resolved_capabilities()
  util.pp_map_clients(function(client)
    return { name = client.name, resolved_capabilities = client.resolved_capabilities }
  end)
end

return M
