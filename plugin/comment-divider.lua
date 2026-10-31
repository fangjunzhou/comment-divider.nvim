if vim.g.loaded_comment_divider then
  return
end
vim.g.loaded_comment_divider = true

local actions = {
  line = "commentLine",
  box = "commentBox",
  filetype = "filetype",
  status = "info",
}

vim.api.nvim_create_user_command("CommentDivider", function(opts)
  local action = actions[opts.args]
  if not action then
    vim.notify("Unknown CommentDivider subcommand: " .. opts.args, vim.log.levels.ERROR)
    return
  end
  require("comment-divider")[action]()
end, {
  nargs = 1,
  complete = function(arg_lead)
    local matches = vim.tbl_filter(function(name)
      return vim.startswith(name, arg_lead)
    end, vim.tbl_keys(actions))
    table.sort(matches)
    return matches
  end,
})
