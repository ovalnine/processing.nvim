-- LSP configuration module
local M = {}

function M.setup(config)
  local lspconfig = require("lspconfig")

  -- Get default capabilities if not provided
  if not config.capabilities then
    config.capabilities = vim.lsp.protocol.make_client_capabilities()
    local ok, cmp_nvim_lsp = pcall(require, "cmp_nvim_lsp")
    if ok then
      config.capabilities = cmp_nvim_lsp.default_capabilities(config.capabilities)
    end
  end

  -- Register the Processing LSP server configuration
  lspconfig.util.default_config = vim.tbl_extend(
    "force",
    lspconfig.util.default_config,
    {
      autostart = config.autostart
    }
  )

  -- Define the processing LSP server if it's not already defined
  require('lspconfig.configs').processing = {
    default_config = {
      cmd = vim.list_extend({ config.processing_path, "lsp" }, config.lsp_args),
      filetypes = config.filetypes,
      root_dir = function(fname)
        return lspconfig.util.find_git_ancestor(fname) or vim.fn.getcwd()
      end,
      settings = config.settings,
      capabilities = config.capabilities,
    },
    docs = {
      description = [[
        Language Server for Processing Framework
        https://processing.org/
        This LSP server requires the Processing binary to be installed and available in your PATH.
      ]],
    },
  }

  -- Setup the LSP server
  lspconfig.processing.setup({
    autostart = config.autostart,
  })
end

return M
