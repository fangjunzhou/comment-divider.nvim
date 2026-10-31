local commentGenerator = {}

--- Fill the width between the delimiters with a solid barrier, centered text,
--- or centered text surrounded by barriers. Any leftover columns become spaces.
---@param text string The comment text; ignored for a solid barrier.
---@param width integer The available width in display columns after indentation.
---@param style CommentDividerStyle The style for the current filetype.
---@param kind "solid"|"decorated"|"centered" The line layout.
---@return string line The generated line without indentation.
local function generate_line(text, width, style, kind)
  -- The delimiters occupy part of the requested width; fill only the space between them.
  -- Use display columns so wide characters and multi-column barriers are measured correctly.
  local inner_width = width - vim.fn.strdisplaywidth(style.lineStart) - vim.fn.strdisplaywidth(style.lineEnd)
  local text_width = vim.fn.strdisplaywidth(text)
  local barrier_width = vim.fn.strdisplaywidth(style.barrierCharacter)
  local barrier = ""
  local edge = ""

  if kind == "solid" then
    -- Reserve at least one space on either side of the solid barrier.
    text = style.barrierCharacter:rep(math.floor((inner_width - 2) / barrier_width))
    text_width = vim.fn.strdisplaywidth(text)
  elseif kind == "decorated" then
    -- Reserve an edge space and a text-adjacent space on each side, then fit
    -- the same number of barrier repetitions to the left and right of the text.
    barrier = style.barrierCharacter:rep(math.floor((inner_width - text_width - 4) / (2 * barrier_width)))
    edge = " "
  end

  -- Center the remaining spaces; an odd extra column goes on the right.
  -- For a centered box line, barrier and edge are empty, so this centers only the text.
  local padding = inner_width - text_width - 2 * vim.fn.strdisplaywidth(barrier) - 2 * #edge
  local left_space = math.floor(padding / 2)
  local right_space = padding - left_space
  return style.lineStart
    .. edge
    .. barrier
    .. (" "):rep(left_space)
    .. text
    .. (" "):rep(right_space)
    .. barrier
    .. edge
    .. style.lineEnd
end

--- Open a line using Neovim's indentation (including indentexpr), then remove
--- the temporary nonblank character so autoindent is retained after leaving Insert mode.
---@return integer buffer The current buffer handle.
---@return integer row The zero-based index of the new line.
---@return string indentation The whitespace inserted by Neovim.
local function open_indented_line()
  local buffer = vim.api.nvim_get_current_buf()
  vim.cmd("normal! $")
  local row = vim.api.nvim_win_get_cursor(0)[1]
  vim.cmd("normal! " .. vim.api.nvim_replace_termcodes("oX<Esc>", true, false, true))
  local indentation = vim.api.nvim_buf_get_lines(buffer, row, row + 1, false)[1]:match("^%s*")
  vim.api.nvim_buf_set_lines(buffer, row, row + 1, false, { indentation })
  return buffer, row, indentation
end

--- Prompt for a comment and insert either a divider line or a three-line box.
--- Remove the provisional indented line if input is canceled or rejected.
---@param config CommentDividerConfig The divider configuration.
---@param is_box boolean Whether to insert a three-line box instead of one line.
local function generate_divider(config, is_box)
  local filetype = vim.bo.filetype
  vim.notify("Current file type: " .. filetype, vim.log.levels.DEBUG)
  local style = config.filetypeStyles[filetype] or config.defaultStyle
  local start_length = vim.fn.strdisplaywidth(style.lineStart)
  local barrier_length = vim.fn.strdisplaywidth(style.barrierCharacter)
  local end_length = vim.fn.strdisplaywidth(style.lineEnd)
  local buffer, row, indentation = open_indented_line()
  local available_width = config.maxLineWidth - vim.fn.strdisplaywidth(indentation)

  vim.ui.input({ prompt = "Enter the comment here: " }, function(comment)
    --- Remove the provisional line after canceled or invalid input.
    local function remove_line()
      vim.api.nvim_buf_set_lines(buffer, row, row + 1, false, {})
    end

    if comment == nil then
      remove_line()
      return
    end
    comment = comment:gsub("^%s*(.-)%s*$", "%1")
    vim.notify("Current buffer line: " .. comment, vim.log.levels.DEBUG)
    local text_length = vim.fn.strdisplaywidth(comment)
    if text_length + start_length + end_length + 2 * barrier_length + 4 > available_width then
      remove_line()
      vim.notify("Comment too long.", vim.log.levels.ERROR)
      return
    end
    if is_box and text_length == 0 then
      remove_line()
      vim.notify("Empty line.", vim.log.levels.INFO)
      return
    end
    local lines = {}
    if is_box then
      local solid = generate_line("", available_width, style, "solid")
      lines = {
        indentation .. solid,
        indentation .. generate_line(comment, available_width, style, "centered"),
        indentation .. solid,
      }
    else
      local kind = text_length > 0 and "decorated" or "solid"
      lines = { indentation .. generate_line(comment, available_width, style, kind) }
    end
    vim.api.nvim_buf_set_lines(buffer, row, row + 1, false, lines)
  end)
end

--- Prompt for text and insert a single comment divider below the cursor.
---@param config CommentDividerConfig The divider configuration.
commentGenerator.commentLine = function(config)
  generate_divider(config, false)
end

--- Prompt for text and insert a three-line comment box below the cursor.
---@param config CommentDividerConfig The divider configuration.
commentGenerator.commentBox = function(config)
  generate_divider(config, true)
end

return commentGenerator
