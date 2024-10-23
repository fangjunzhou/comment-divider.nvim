# comment-divider.nvim

https://github.com/user-attachments/assets/73103a2c-ba39-4349-b488-b6f3585042b7

This project is meant to replace the [Comment Divider](https://github.com/stackbreak/comment-divider) for VSCode in NeoVim.

## Install

Install `fangjunzhou/comment-divider.nvim` from your package manager.

### Config

This is the default config:

```lua
{
	debug = true, -- Whether to enable developer debug info.
	commentLength = 64, -- The length of divide line and box.
	defaultConfig = { -- Default config for unknown filetype.
		lineStart = "/*",
		lineSeperator = "-",
		lineEnd = "*/",
	},
	languageConfig = { -- language dependent config.
		cpp = {
			lineStart = "/*",
			lineSeperator = "-",
			lineEnd = "*/",
		},
		python = {
			lineStart = "#",
			lineSeperator = "-",
			lineEnd = "#",
		},
		lua = {
			lineStart = "--",
			lineSeperator = "-",
			lineEnd = "--",
		},
	},
}
```

## Features

- Comment divider line.
- Comment divider box.
- Solid divider line.
- Automatically apply different comment divider styles for different languages.
- Check current `filetype` by `CommenDividerFileType`

## Commands

- `CommentDividerLine` to create a comment divide line. If the comment is empty, a solid line will be added.
- `CommentDividerBox` to create a comment divide box.
- `CommentDividerFiletype` to check the file type of current buffer.
- `CommentDividerConfigInfo` to get the current config.

### Example
```c++
/* ------------------- Print Hello World  ------------------- */
std::cout << "Hello World!" << std::endl;

/* ---------------------------------------------------------- */
/*                  Print Hello World Again                   */
/* ---------------------------------------------------------- */
std::cout << "Hello World Again!" << std::endl;

// This is a solid comment divider line:
/* ---------------------------------------------------------- */
```
