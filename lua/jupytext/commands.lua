local M = {}

local try_python_module_execution = function(input_file, options)
  -- Try using python -m jupytext as fallback
  local python_commands = {"python3", "python", "py"}
  
  for _, python_cmd in ipairs(python_commands) do
    local cmd_parts = {python_cmd, "-m", "jupytext", input_file}
    
    for option_name, option_value in pairs(options) do
      if option_value ~= "" then
        table.insert(cmd_parts, option_name .. "=" .. option_value)
      else
        table.insert(cmd_parts, option_name)
      end
    end
    
    local cmd = table.concat(cmd_parts, " ")
    print("Trying fallback command: " .. cmd)
    
    local output = vim.fn.system(cmd)
    
    if vim.v.shell_error == 0 then
      print("Success with " .. python_cmd .. " -m jupytext")
      return true
    end
  end
  
  return false
end

M.run_jupytext_command = function(input_file, options)
  local cmd_parts = {"jupytext", input_file}
  
  for option_name, option_value in pairs(options) do
    if option_value ~= "" then
      table.insert(cmd_parts, option_name .. "=" .. option_value)
    else
      -- empty string value implies this option is just a flag
      table.insert(cmd_parts, option_name)
    end
  end

  local cmd = table.concat(cmd_parts, " ")
  
  local output = vim.fn.system(cmd)

  if vim.v.shell_error ~= 0 then
    vim.api.nvim_err_writeln("Primary command failed: " .. cmd)
    vim.api.nvim_err_writeln("Error code: " .. vim.v.shell_error)
    vim.api.nvim_err_writeln("Output: " .. output)
    
    -- Try fallback method using python -m jupytext
    print("Attempting fallback execution method...")
    if try_python_module_execution(input_file, options) then
      return true
    else
      vim.api.nvim_err_writeln("All execution methods failed")
      vim.api.nvim_err_writeln("Make sure jupytext is installed: pip install jupytext")
      return false
    end
  end
  
  return true
end

return M