-- Comment divider line.
vim.api.nvim_create_user_command("CommentDividerLine", function()
	require("comment-divider").commentLine()
end, {
	nargs = 0,
})

vim.api.nvim_create_user_command("CommentDividerBox", function()
	require("comment-divider").commentBox()
end, {
	nargs = 0,
})

-- Check current filetype.
vim.api.nvim_create_user_command("CommentDividerFiletype", function()
	require("comment-divider").checkFiletype()
end, {
	nargs = 0,
})
