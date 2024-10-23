local commentConfig = require("comment-divider.comment-config")
local commentGenerator = require("comment-divider.comment-generator")

local M = {}

--- Setup function for package managers.
---@param config table config for
M.setup = function(config)
	-- Merge config.
	commentConfig = vim.tbl_deep_extend("force", commentConfig, config or {})
end

--- Display plugin config info.
M.info = function()
	local commentDividerInfo = "Current comment divider config:"
	commentDividerInfo = commentDividerInfo .. "\n" .. vim.inspect(commentConfig)
	print(commentDividerInfo)
end

--- Display filetype for current buffer.
M.filetype = function()
	local currFiletype = vim.api.nvim_buf_get_option(0, "filetype")
	print("Current buffer filetype: " .. currFiletype)
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
	local reload = require("plenary.reload").reload_module
	reload("comment-divider", true)
end

return M
