---@class CommentDividerStyle
---@field lineStart string The opening comment delimiter.
---@field barrierCharacter string The repeated barrier text.
---@field lineEnd string The closing comment delimiter.

---@class CommentDividerConfig
---@field maxLineWidth integer The target line width in display columns.
---@field defaultStyle CommentDividerStyle The style for unmatched filetypes.
---@field filetypeStyles table<string, CommentDividerStyle> Styles keyed by buffer filetype.

---@class CommentDividerStyleOptions
---@field lineStart? string The opening comment delimiter.
---@field barrierCharacter? string The repeated barrier text.
---@field lineEnd? string The closing comment delimiter.

---@class CommentDividerOptions
---@field maxLineWidth? integer The target line width in display columns.
---@field defaultStyle? CommentDividerStyleOptions The fallback style.
---@field filetypeStyles? table<string, CommentDividerStyleOptions> Styles keyed by filetype.

---@type CommentDividerConfig
local commentConfig = {
  maxLineWidth = 80,
  defaultStyle = {
    lineStart = "/*",
    barrierCharacter = "-",
    lineEnd = "*/",
  },
  filetypeStyles = {
    cpp = {
      lineStart = "/*",
      barrierCharacter = "-",
      lineEnd = "*/",
    },
    python = {
      lineStart = "#",
      barrierCharacter = "-",
      lineEnd = "#",
    },
    lua = {
      lineStart = "--",
      barrierCharacter = "-",
      lineEnd = "--",
    },
  },
}

return commentConfig
