-- Development reload.
vim.api.nvim_create_user_command("CommentDividerReload", function()
	require("comment-divider").reload()
end, {
	nargs = 0,
})
