local plenary_dir = assert(vim.env.PLENARY_DIR, "Run tests with nix run .#test")

vim.opt.runtimepath:prepend(".")
vim.opt.runtimepath:append(plenary_dir)

vim.cmd("runtime plugin/plenary.vim")
require("plenary.busted")
