local M = {}

local language_extensions = {
  python = "py",
  julia = "jl",
  r = "r",
  R = "r",
  bash = "sh",
}
language_extensions["c++"] = "cpp"

local language_names = {
  python3 = "python",
}

M.get_ipynb_metadata = function(filename)
  local file = io.open(filename, "r")
  if not file then
    error("Could not open file: " .. filename)
  end
  
  local content = file:read("*a")
  file:close()
  
  local ok, parsed = pcall(vim.json.decode, content)
  if not ok then
    error("Failed to parse JSON from: " .. filename)
  end
  
  local metadata = parsed.metadata
  if not metadata then
    error("No metadata found in notebook: " .. filename)
  end
  
  if not metadata.kernelspec then
    error("No kernelspec found in metadata: " .. filename)
  end
  
  local language = metadata.kernelspec.language
  if language == nil then
    language = language_names[metadata.kernelspec.name]
  end
  
  if not language then
    error("Could not determine language from kernelspec in: " .. filename)
  end
  
  local extension = language_extensions[language]
  if not extension then
    -- Default to the language name as extension if not found
    extension = language
  end

  return { language = language, extension = extension }
end

M.get_jupytext_file = function(filename, extension)
  local fileroot = vim.fn.fnamemodify(filename, ":r")
  return fileroot .. "." .. extension
end

M.check_key = function(tbl, key)
  return tbl[key] ~= nil
end

return M