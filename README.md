# comment-divider.nvim

This project is meant to replacement the [Comment Divider](https://github.com/stackbreak/comment-divider) for VSCode in NeoVim.

## Features

- Comment divider line.
- Comment divider box.
- Solid divider line.
- Automatically apply different comment divider style for different language.
- Check current `filetype` by `CommenDividerFileType`

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

## Install

Install `Fangjun-Zhou/comment-divider.nvim` from your package manager.
