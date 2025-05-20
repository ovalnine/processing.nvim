# Processing.nvim

A Neovim plugin for [Processing](https://processing.org/) development with LSP support, code running capabilities, and more.

## Features

- Processing LSP integration
- Run Processing sketches directly from Neovim
- Run sketches in presentation mode
- Export sketches to different platforms (macOS, Windows, Linux)
- Create new Processing sketches with a template
- File type detection for `.pde` files
- Syntax highlighting via Treesitter using Java parser

## Requirements

- Neovim >= 0.7.0
- [Processing](https://processing.org/) installed (version 4.4.0+) and available in your PATH
- `nvim-lspconfig` plugin
- Optional: `cmp-nvim-lsp` for enhanced completion

## Installation

### Using Lazy.nvim

```lua
return {
  "your-username/processing.nvim",
  dependencies = {
    "neovim/nvim-lspconfig",
    -- Optional dependencies
    "hrsh7th/cmp-nvim-lsp", -- For enhanced LSP completions
  },
  config = function()
    require("processing").setup({
      -- Optional: custom configuration
      processing_path = "processing", -- Path to processing executable
      mappings = {
        run = "<leader>pr",
        present = "<leader>pp",
        export = "<leader>pe",
        create = "<leader>pc",
      },
    })
  end,
  ft = { "processing", "pde" }, -- Load only for Processing files
}
```

### Using packer.nvim

```lua
use {
  "your-username/processing.nvim",
  requires = {
    "neovim/nvim-lspconfig",
    -- Optional dependencies
    "hrsh7th/cmp-nvim-lsp", -- For enhanced LSP completions
  },
  config = function()
    require("processing").setup({
      -- Optional: custom configuration
    })
  end,
}
```

## Configuration

Default configuration:

```lua
require("processing").setup({
  -- Path to the Processing binary
  processing_path = "processing",
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
})
```

## Commands

The following commands are available:

- `:ProcessingRun` - Run the current Processing sketch
- `:ProcessingPresent` - Run the current sketch in presentation mode
- `:ProcessingExport` - Export the current sketch (prompts for variant and output dir)
- `:ProcessingCreate` - Create a new Processing sketch with a template

## Key Mappings

When editing Processing files, the following default key mappings are available:

- `<leader>pr` - Run the current Processing sketch
- `<leader>pp` - Run the current sketch in presentation mode
- `<leader>pe` - Export the current Processing sketch
- `<leader>pc` - Create a new Processing sketch

You can customize these mappings in the setup function.

## Export Variants

When exporting a sketch, you'll be prompted to select a variant (platform-architecture):

- `macos-x86_64` - macOS (Intel 64-bit)
- `macos-aarch64` - macOS (Apple Silicon)
- `windows-amd64` - Windows (Intel 64-bit)
- `linux-amd64` - Linux (Intel 64-bit)
- `linux-arm` - Linux (Raspberry Pi 32-bit)
- `linux-aarch64` - Linux (Raspberry Pi 64-bit)

## Development Status

This plugin is in active development. Feel free to contribute by submitting issues or pull requests.

## License

MIT
