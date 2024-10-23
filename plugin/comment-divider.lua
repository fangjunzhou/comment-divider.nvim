-- Comment divider line.
vim.api.nvim_create_user_command("CommentDividerLine", function()
	require("comment-divider").commentLine()
end, { nargs = 0 })

-- Comment divider box.
vim.api.nvim_create_user_command("CommentDividerBox", function()
	require("comment-divider").commentBox()
end, { nargs = 0 })

-- Show current config.
vim.api.nvim_create_user_command("CommentDividerConfigInfo", function()
	require("comment-divider").info()
end, { nargs = 0 })

-- Check current filetype.
vim.api.nvim_create_user_command("CommentDividerFiletype", function()
	require("comment-divider").filetype()
end, { nargs = 0 })
