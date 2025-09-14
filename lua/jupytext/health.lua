local M = {}

M.check = function()
  vim.health.start "jupytext.nvim"
  
  -- Check if jupytext is available
  local output = vim.fn.system "jupytext --version"

  if vim.v.shell_error == 0 then
    vim.health.ok("Jupytext is available (version: " .. vim.trim(output) .. ")")
  else
    vim.health.error("Jupytext is not available", "Install jupytext via `pip install jupytext`")
  end
  
  -- Check if we can write to temporary directory
  local temp_dir = vim.fn.tempname()
  local test_write = io.open(temp_dir, "w")
  if test_write then
    test_write:close()
    vim.fn.delete(temp_dir)
    vim.health.ok("File system write access is available")
  else
    vim.health.warn("Unable to write temporary files", "Check file system permissions")
  end
end

return M
