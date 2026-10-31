local commentConfig = require("comment-divider.comment-config")
local commentGenerator = require("comment-divider.comment-generator")

local M = {}

--- Setup function for package managers.
---@param config table config for setup.
M.setup = function(config)
  -- Merge config.
  commentConfig = vim.tbl_deep_extend("force", commentConfig, config or {})
end

--- Display plugin config info.
M.info = function()
  local commentDividerInfo = "Current comment divider config:"
  commentDividerInfo = commentDividerInfo .. "\n" .. vim.inspect(commentConfig)
  vim.notify(commentDividerInfo, vim.log.levels.INFO)
end

--- Copy the current buffer filetype to the clipboard.
M.filetype = function()
  local currFiletype = vim.api.nvim_buf_get_option(0, "filetype")
  vim.fn.setreg("+", currFiletype)
  vim.notify("Filetype copied to clipboard: " .. currFiletype, vim.log.levels.INFO)
end

--- Generate comment divider line.
M.commentLine = function()
  commentGenerator.commentLine(commentConfig)
end

--- Generate comment divider box.
M.commentBox = function()
  commentGenerator.commentBox(commentConfig)
end

--- Reload module for development.
M.reload = function()
  for name in pairs(package.loaded) do
    if name == "comment-divider" or name:match("^comment%-divider%.") then
      package.loaded[name] = nil
    end
  end
end

return M
