local commentGenerator = {}

--- Generate comment divider line.
---@param bufLine string current buffer conetnt.
---@param bufLineLength number the length of current buffer line.
---@param commentLength number the total length of the comment divider.
---@param languageConfig table the language specific comment divider config.
---@param endLength number the length of lineEnd.
---@param seperatorLength number the length of lineSeperator.
---@param startLength number the length of lineStart.
---@return string lineStr the generated comment divider line.
local function generateCommentLine(
  bufLine,
  bufLineLength,
  commentLength,
  languageConfig,
  endLength,
  seperatorLength,
  startLength
)
  -- Calculate the left and right seperatorLength.
  -- Half of the seperator length.
  local seperatorLengthHalf = math.floor((commentLength - startLength - endLength - 4 - bufLineLength) / 2)
  -- Number of seperator per half.
  local seperatorNum = math.floor(seperatorLengthHalf / seperatorLength)
  -- Number of spaces in the center.
  local centerSpace = commentLength - startLength - endLength - 2 - seperatorNum * 2 * seperatorLength - bufLineLength
  local leftCenterSpace = math.floor(centerSpace / 2)
  local rightCenterSpace = math.floor((centerSpace + 1) / 2)

  -- Construct the comment line.
  local lineStr = ""
  -- Start
  lineStr = lineStr .. languageConfig.lineStart .. " "
  -- Left seperator.
  for _ = 1, seperatorNum do
    lineStr = lineStr .. languageConfig.lineSeperator
  end
  -- Left center space.
  for _ = 1, leftCenterSpace do
    lineStr = lineStr .. " "
  end
  -- Buffer line text.
  lineStr = lineStr .. bufLine
  -- Right center space.
  for _ = 1, rightCenterSpace do
    lineStr = lineStr .. " "
  end
  -- Right seperator.
  for _ = 1, seperatorNum do
    lineStr = lineStr .. languageConfig.lineSeperator
  end
  -- End
  lineStr = lineStr .. " " .. languageConfig.lineEnd
  return lineStr
end


--- Generate comment line divider.
---@param config table config for comment generator.
commentGenerator.commentLine = function(config)
  -- Debug enabled.
  local isDebug = config.debug
  -- Total length of the comment line.
  local commentLength = config.commentLength
  -- Get current filetype.
  local filetype = vim.api.nvim_buf_get_option(0, "filetype")
  if isDebug then
    print("Current file type: " .. filetype)
  end
  -- Get the language config for current filetype.
  local languageConfig = config.languageConfig[filetype]
  languageConfig = languageConfig or config.defaultConfig
  -- Length for line components.
  local startLength = string.len(languageConfig.lineStart)
  local seperatorLength = string.len(languageConfig.lineSeperator)
  local endLength = string.len(languageConfig.lineEnd)

  -- Get current line.
  local bufLine = vim.api.nvim_get_current_line()
  -- Trim all the white spaces.
  bufLine = bufLine:gsub("^%s*(.-)%s*$", "%1")
  if isDebug then
    print("Current buffer line: " .. bufLine)
  end
  -- The length of current buffer line.
  local bufLineLength = bufLine:len()

  -- Calculate how many characters are needed for minimum seperator.
  -- /* - text - */
  local minSeperatorLength = startLength + endLength + 2 * seperatorLength + 4
  if bufLineLength + minSeperatorLength > commentLength then
    print("Comment too long.")
    return
  end

  if bufLineLength > 0 then
    -- Generate comment divider when bufLineLength > 0.
    local lineStr = generateCommentLine(
      bufLine,
      bufLineLength,
      commentLength,
      languageConfig,
      endLength,
      seperatorLength,
      startLength
    )
  else
    -- TODO: Generate a solid line.
  end

  -- Write line.
  vim.api.nvim_set_current_line(lineStr)
end

return commentGenerator
