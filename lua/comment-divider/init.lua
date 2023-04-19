local commentConfig = require("comment-divider.comment-config")
local commentGenerator = require("comment-divider.comment-generator")

local M = {}

--- Setup function for package managers.
---@param config table config for
M.setup = function(config)
	-- Merge config.
	commentConfig = vim.tbl_deep_extend("force", commentConfig, config or {})
end

--- Function for plugin information.
M.info = function()
	local commentDividerInfo = "Comment Divider for NeoVim"
	commentDividerInfo = commentDividerInfo .. "\n" .. vim.inspect(commentConfig)
	print(commentDividerInfo)
end

M.checkFiletype = function()
	local currFiletype = vim.api.nvim_buf_get_option(0, "filetype")
	print("Current filetype: " .. currFiletype)
end

--- Generate comment divider line.
M.commentLine = function()
	commentGenerator.commentLine(commentConfig)
end

--- Reload module for development.
M.reload = function()
	local reload = require("plenary.reload").reload_module
	reload("comment-divider", true)
end

return M
