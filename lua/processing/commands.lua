-- Processing-specific commands
local M = {}

local function get_sketch_path()
  local current_file = vim.fn.expand('%')
  local sketch_dir = vim.fn.fnamemodify(current_file, ':p:h')
  local sketch_name = vim.fn.fnamemodify(sketch_dir, ':t')
  return sketch_dir, sketch_name
end

-- Get the Processing CLI path
local function get_processing_cli_path(config)
  if config.processing_cli_path then
    return config.processing_cli_path
  else
    return config.processing_path .. " cli"
  end
end

-- Helper function to build Processing CLI command
local function build_processing_command(config, action, args)
  local sketch_dir, sketch_name = get_sketch_path()

  -- Check if we're in a Processing sketch
  if not vim.tbl_contains(config.filetypes, vim.bo.filetype) then
    vim.notify("Not in a Processing file", vim.log.levels.ERROR)
    return nil
  end

  -- Save all buffers before running
  vim.cmd('silent! wall')

  -- Construct the base command
  local cmd_parts = {
    get_processing_cli_path(config),
    "--sketch=" .. sketch_dir,
    "--force",
  }

  -- Add the requested action
  if action == "run" then
    table.insert(cmd_parts, "--run")
  elseif action == "present" then
    table.insert(cmd_parts, "--present")
  elseif action == "export" then
    table.insert(cmd_parts, "--export")

    -- Add export-specific options
    if args.variant then
      table.insert(cmd_parts, "--variant=" .. args.variant)
    end

    if not config.embed_java then
      table.insert(cmd_parts, "--no-java")
    end

    if args.output then
      table.insert(cmd_parts, "--output=" .. args.output)
    end
  end

  return table.concat(cmd_parts, " ")
end

-- Run the current Processing sketch
function M.run_sketch()
  local cmd = build_processing_command(vim.g.processing_config, "run")
  if not cmd then return end

  -- Create a new terminal buffer for the output
  vim.cmd('new')

  -- Run the command in the terminal
  vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("Processing sketch exited with code " .. exit_code, vim.log.levels.ERROR)
      end
    end,
  })

  -- Enter insert mode in the terminal
  vim.cmd('startinsert')
end

-- Run the current Processing sketch in presentation mode
function M.present_sketch()
  local cmd = build_processing_command(vim.g.processing_config, "present")
  if not cmd then return end

  -- Create a new terminal buffer for the output
  vim.cmd('new')

  -- Run the command in the terminal
  vim.fn.termopen(cmd, {
    on_exit = function(_, exit_code)
      if exit_code ~= 0 then
        vim.notify("Processing presentation exited with code " .. exit_code, vim.log.levels.ERROR)
      end
    end,
  })

  -- Enter insert mode in the terminal
  vim.cmd('startinsert')
end

-- Export the current Processing sketch
function M.export_sketch()
  local sketch_dir, sketch_name = get_sketch_path()

  -- Check if we're in a Processing sketch
  if not vim.tbl_contains(vim.g.processing_config.filetypes, vim.bo.filetype) then
    vim.notify("Not in a Processing file", vim.log.levels.ERROR)
    return
  end

  -- Save all buffers before exporting
  vim.cmd('silent! wall')

  -- Prompt for export variant
  vim.ui.select(
    {
      "macos-x86_64",
      "macos-aarch64",
      "windows-amd64",
      "linux-amd64",
      "linux-arm",
      "linux-aarch64"
    },
    {
      prompt = "Select export variant (platform-architecture):",
      default = vim.g.processing_config.default_variant
    },
    function(variant)
      if not variant then return end

      -- Prompt for output directory
      vim.ui.input({
        prompt = "Export directory (leave empty for default): ",
      }, function(output_dir)
        -- Build export args
        local args = {
          variant = variant
        }

        if output_dir and output_dir ~= "" then
          args.output = output_dir
        end

        -- Build and run the command
        local cmd = build_processing_command(vim.g.processing_config, "export", args)
        if not cmd then return end

        -- Create a new terminal buffer for the output
        vim.cmd('new')

        -- Run the command in the terminal
        vim.fn.termopen(cmd, {
          on_exit = function(_, exit_code)
            if exit_code ~= 0 then
              vim.notify("Processing export exited with code " .. exit_code, vim.log.levels.ERROR)
            else
              vim.notify("Sketch exported successfully as " .. variant, vim.log.levels.INFO)
            end
          end,
        })

        -- Enter insert mode in the terminal
        vim.cmd('startinsert')
      end)
    end
  )
end

-- Create Processing sketch
function M.create_sketch()
  vim.ui.input({
    prompt = "Enter sketch name: ",
  }, function(sketch_name)
    if not sketch_name or sketch_name == "" then
      return
    end

    -- Create sketch directory
    local sketch_dir = vim.fn.expand('~') .. '/Processing/' .. sketch_name
    vim.fn.mkdir(sketch_dir, "p")

    -- Create main sketch file
    local sketch_file = sketch_dir .. '/' .. sketch_name .. '.pde'
    local template = [[
void setup() {
  size(800, 600);
  // Initialize your sketch here
}

void draw() {
  // Draw your sketch here
  background(220);
}
]]

    -- Write template to file
    vim.fn.writefile(vim.split(template, '\n'), sketch_file)

    -- Open the new sketch file
    vim.cmd('edit ' .. sketch_file)

    vim.notify("Created new Processing sketch: " .. sketch_name, vim.log.levels.INFO)
  end)
end

-- Setup commands and keymaps
function M.setup(config)
  -- Store processing config in a global variable for access from command functions
  vim.g.processing_config = config

  -- Create user commands
  vim.api.nvim_create_user_command('ProcessingRun', M.run_sketch, {
    desc = 'Run the current Processing sketch'
  })

  vim.api.nvim_create_user_command('ProcessingPresent', M.present_sketch, {
    desc = 'Run the current Processing sketch in presentation mode'
  })

  vim.api.nvim_create_user_command('ProcessingExport', M.export_sketch, {
    desc = 'Export the current Processing sketch'
  })

  vim.api.nvim_create_user_command('ProcessingCreate', M.create_sketch, {
    desc = 'Create a new Processing sketch'
  })

  -- Setup key mappings if filetypes match
  if config.mappings then
    vim.api.nvim_create_autocmd("FileType", {
      pattern = config.filetypes,
      callback = function()
        -- Set up processing-specific keymaps
        if config.mappings.run then
          vim.keymap.set("n", config.mappings.run, M.run_sketch, {
            buffer = true,
            desc = "Run Processing sketch"
          })
        end

        if config.mappings.present then
          vim.keymap.set("n", config.mappings.present, M.present_sketch, {
            buffer = true,
            desc = "Run Processing sketch in presentation mode"
          })
        end

        if config.mappings.export then
          vim.keymap.set("n", config.mappings.export, M.export_sketch, {
            buffer = true,
            desc = "Export Processing sketch"
          })
        end

        if config.mappings.create then
          vim.keymap.set("n", config.mappings.create, M.create_sketch, {
            buffer = true,
            desc = "Create new Processing sketch"
          })
        end
      end
    })
  end
end

return M
