-- Main plugin module
local M = {}

-- Default configuration
M.config = {
  -- Path to the Processing binary
  processing_path = "Processing",
  -- Path to the Processing cli mode binary (will use processing_path + cli if not specified)
  processing_cli_path = nil,
  -- Additional arguments to pass to the Processing LSP server
  lsp_args = {},
  -- Filetypes to associate with the Processing LSP
  filetypes = { "processing", "pde" },
  -- Whether to enable autostart of the LSP for matching filetypes
  autostart = true,
  -- Additional LSP settings to pass to the server
  settings = {},
  -- LSP capabilities
  capabilities = nil,
  -- Auto commands to be created
  auto_commands = true,
  -- Default export variant (platform-architecture)
  default_variant = "macos-x86_64", -- or "macos-aarch64", "windows-amd64", "linux-amd64", etc.
  -- Whether to embed Java in exports (default: true)
  embed_java = true,
  -- Key mappings for Processing-specific commands
  mappings = {
    -- Run the current sketch
    run = "<leader>pr",
    -- Run the current sketch in presentation mode
    present = "<leader>pp",
    -- Export the current sketch
    export = "<leader>pe",
    -- Create a new sketch
    create = "<leader>pc",
  },
}

-- Setup function to be called by the plugin manager
function M.setup(opts)
  -- Merge user config with defaults
  opts = opts or {}
  for k, v in pairs(opts) do
    M.config[k] = v
  end

  -- Check if processing is available
  if vim.fn.executable(M.config.processing_path) ~= 1 then
    vim.notify("Processing binary not found. Please install Processing or set the correct path.", vim.log.levels.ERROR)
    return
  end

  -- Register filetype detection
  if M.config.auto_commands then
    vim.api.nvim_create_autocmd({"BufNewFile", "BufRead"}, {
      pattern = "*.pde",
      callback = function()
        vim.bo.filetype = "processing"
        -- Optionally force a specific parser if different from the filetype
        vim.cmd("TSBufEnable highlight")
        vim.treesitter.start(0, "java")  -- Use the Java parser for this buffer
      end
    })
  end

  -- Setup the LSP server
  require("lsp").setup(M.config)

  -- Setup commands
  require("commands").setup(M.config)
end

return M
