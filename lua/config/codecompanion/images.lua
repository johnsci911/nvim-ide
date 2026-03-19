-- lua/config/codecompanion/images.lua
local M = {}

-- Base directory for all codecompanion images
M.base_dir = vim.fn.stdpath("data") .. "/codecompanion/images"

--- Ensure the base images directory exists
function M.ensure_base_dir()
  vim.fn.mkdir(M.base_dir, "p")
end

--- Get (and create) a stable directory for a given session key
--- @param session_key string  any unique string (e.g. chat bufnr or uuid)
--- @return string  the directory path
function M.session_dir(session_key)
  local dir = M.base_dir .. "/" .. tostring(session_key)
  vim.fn.mkdir(dir, "p")
  return dir
end

--- Generate a stable image file path for a given session
--- @param session_key string
--- @return string  full path ending in .png
function M.new_image_path(session_key)
  local dir = M.session_dir(session_key)
  -- Use timestamp + random for uniqueness within a session
  local name = os.time() .. "_" .. math.random(1000, 9999) .. ".png"
  return dir .. "/" .. name
end

--- Delete all images for a session
--- @param session_key string
function M.cleanup_session(session_key)
  local dir = M.base_dir .. "/" .. tostring(session_key)
  if vim.fn.isdirectory(dir) == 1 then
    vim.fn.delete(dir, "rf")
  end
end

--- Delete all images in all session dirs (full wipe)
function M.cleanup_all()
  if vim.fn.isdirectory(M.base_dir) == 1 then
    vim.fn.delete(M.base_dir, "rf")
    vim.fn.mkdir(M.base_dir, "p")
  end
end

return M
