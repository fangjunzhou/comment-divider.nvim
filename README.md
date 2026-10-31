<picture>
  <source media="(prefers-color-scheme: dark)" srcset="assets/wordmark-dark.svg">
  <source media="(prefers-color-scheme: light)" srcset="assets/wordmark-light.svg">
  <img alt="comment-divider.nvim" src="assets/wordmark-light.svg" width="524" height="120">
</picture>

[Demo video](assets/demo.mp4)

Add comment dividers and boxes in Neovim, inspired by the VSCode
[Comment Divider](https://github.com/stackbreak/comment-divider) extension.

## Get Started

### Installation

#### LazyVim

Add this to `~/.config/nvim/lua/plugins/comment-divider.lua`:

```lua
return {
  {
    "fangjunzhou/comment-divider.nvim",
    main = "comment-divider",
    cmd = "CommentDivider",
    opts = {
      maxLineWidth = 64,
    },
  },
}
```

LazyVim loads the plugin when you run `:CommentDivider` and passes `opts` to
`setup()`. Remove `maxLineWidth` to use the default of 80.

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

- `:CommentDivider line` adds a divider below the current line. Leave the prompt
  empty for a divider without text.
- `:CommentDivider box` adds a three-line box below the current line.
- `:CommentDivider status` shows your settings.
- `:CommentDivider filetype` copies the current file type to the clipboard and
  shows it on screen.

Press Tab after `:CommentDivider ` to see the options.

These examples use C++ comments and `maxLineWidth = 64`. The divider appears
below the line where your cursor is.

#### Divider with text

Run `:CommentDivider line` and enter `Hello`:

```cpp
do_work();
/* ------------------------- Hello  ------------------------- */
```

#### Divider without text

Run `:CommentDivider line` and press Enter without typing anything:

```cpp
do_work();
/* ---------------------------------------------------------- */
```

#### Box

Run `:CommentDivider box` and enter `Hello`:

```cpp
do_work();
/* ---------------------------------------------------------- */
/*                           Hello                            */
/* ---------------------------------------------------------- */
```

#### Divider with Indentation

Comment divider will automatically adapt to the configured max line width with indentation.

```cpp
/* ------------------------- Hello  ------------------------- */
void run() {
    do_work();
    /* ----------------------- Hello  ----------------------- */
}
```

Neovim sets the indentation, which counts toward the width (four spaces leave
60 columns above). Extra spaces around text are removed. Canceling changes
nothing; text that does not fit shows `Comment too long.` instead of a divider.
Boxes need text.

### Configuration

Setup is optional. These are the defaults:

```lua
require("comment-divider").setup({
  maxLineWidth = 80,
  defaultStyle = {
    lineStart = "/*",
    barrierCharacter = "-",
    lineEnd = "*/",
  },
  filetypeStyles = {
    cpp = { lineStart = "/*", barrierCharacter = "-", lineEnd = "*/" },
    python = { lineStart = "#", barrierCharacter = "-", lineEnd = "#" },
    lua = { lineStart = "--", barrierCharacter = "-", lineEnd = "--" },
  },
})
```

Other file types use `defaultStyle`. `maxLineWidth` counts on-screen columns,
including indentation.
`barrierCharacter` must not be empty. Debug messages use Neovim's DEBUG
notification level.

For HTML, use its `<!-- ... -->` comment markers with `-` barriers:

```lua
require("comment-divider").setup({
  filetypeStyles = {
    html = { lineStart = "<!--", barrierCharacter = "-", lineEnd = "-->" },
  },
})
```

At the default width of 80, entering `Hello` in an HTML buffer produces:

```html
<!-- -------------------------------- Hello -------------------------------- -->
```

The existing styles stay unchanged.

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
