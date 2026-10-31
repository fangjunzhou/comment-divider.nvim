# comment-divider.nvim

https://github.com/user-attachments/assets/73103a2c-ba39-4349-b488-b6f3585042b7

Comment divider lines and boxes for Neovim, inspired by the VSCode
[Comment Divider](https://github.com/stackbreak/comment-divider) extension.
There are no runtime dependencies. Styles are selected by buffer filetype.

## Get Started

### Installation

#### LazyVim

Create `~/.config/nvim/lua/plugins/comment-divider.lua` with this
[plugin spec](https://www.lazyvim.org/configuration/plugins):

```lua
return {
  {
    "fangjunzhou/comment-divider.nvim",
    cmd = {
      "CommentDividerLine",
      "CommentDividerBox",
      "CommentDividerConfigInfo",
      "CommentDividerFiletype",
    },
    opts = {},
  },
}
```

#### Nixvim

Add this to your [Nixvim configuration](https://nix-community.github.io/nixvim/user-guide/faq.html#how-do-i-use-a-plugin-not-packaged-in-nixpkgs).
Replace `REVISION` with a commit hash and `SHA256` with its Nix source hash.
For NixOS or Home Manager, put these options under `programs.nixvim`.

```nix
{ pkgs, ... }:
{
  extraPlugins = [
    (pkgs.vimUtils.buildVimPlugin {
      pname = "comment-divider.nvim";
      version = "unstable";
      src = pkgs.fetchFromGitHub {
        owner = "fangjunzhou";
        repo = "comment-divider.nvim";
        rev = "REVISION";
        hash = "SHA256";
      };
    })
  ];

  extraConfigLua = ''
    require("comment-divider").setup({})
  '';
}
```

#### Local Checkout

From the repository root:

```sh
nvim --clean --cmd "set runtimepath+=."
```

### Usage

- `:CommentDividerLine` prompts for text and inserts a divider below the cursor.
  Submit empty text for a solid line.
- `:CommentDividerBox` prompts for text and inserts a three-line box below the cursor.
- `:CommentDividerConfigInfo` displays the current configuration.
- `:CommentDividerFiletype` copies the current buffer filetype to the clipboard
  and displays an informational notification.

Cancel the prompt to leave the buffer unchanged. Text is trimmed; text that is
too long is rejected. Boxes require nonempty text.

```cpp
/* --------------------- Print Hello World --------------------- */
std::cout << "Hello World!" << std::endl;

/* ------------------------------------------------------------ */
/*                   Print Hello World Again                    */
/* ------------------------------------------------------------ */
```

### Configuration

Setup is optional. These are the defaults:

```lua
require("comment-divider").setup({
  debug = true,
  commentLength = 64,
  defaultConfig = {
    lineStart = "/*",
    lineSeperator = "-",
    lineEnd = "*/",
  },
  languageConfig = {
    cpp = { lineStart = "/*", lineSeperator = "-", lineEnd = "*/" },
    python = { lineStart = "#", lineSeperator = "-", lineEnd = "#" },
    lua = { lineStart = "--", lineSeperator = "-", lineEnd = "--" },
  },
})
```

`setup()` deep-merges options into the current configuration. Other filetypes use
`defaultConfig`. Set `debug = false` to silence diagnostic messages. Widths are
measured in bytes, not display columns. Use a positive `commentLength` large
enough for the delimiters and text, and a nonempty `lineSeperator`.
The spelling `lineSeperator` is part of the existing configuration API.

The Lua API also exposes `commentLine()`, `commentBox()`, `info()`, and `filetype()`:

```lua
vim.keymap.set("n", "<leader>cl", function()
  require("comment-divider").commentLine()
end, { desc = "Comment divider line" })

vim.keymap.set("n", "<leader>cb", function()
  require("comment-divider").commentBox()
end, { desc = "Comment divider box" })
```

## Development

See [AGENTS.md](AGENTS.md) for requirements, commands, and contribution guidelines.

## License

MIT. See [LICENSE](LICENSE).
