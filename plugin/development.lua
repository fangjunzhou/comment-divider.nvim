-- Comment divider line.
vim.api.nvim_create_user_command("CommentDividerLine", function()
	require("comment-divider").commentLine()
end, {
	nargs = 0,
})

-- Development reload.
vim.api.nvim_create_user_command("CommentDividerReload", function()
	require("comment-divider").reload()
end, {
	nargs = 0,
})
