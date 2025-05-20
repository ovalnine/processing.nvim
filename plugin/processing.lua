-- Plugin: processing.nvim
-- Author: Your Name
-- License: MIT
-- Description: Processing framework integration for Neovim

if vim.fn.has('nvim-0.7.0') ~= 1 then
  vim.api.nvim_err_writeln("Processing.nvim requires at least Neovim v0.7.0")
  return
end

-- Forward to the setup function
return require('processing')
