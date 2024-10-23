local commentGenerator = {}

--- Generate comment divider line.
---@param comment string current buffer conetnt.
---@param bufLineLength number the length of current buffer line.
---@param commentLength number the total length of the comment divider.
---@param languageConfig table the language specific comment divider config.
---@param endLength number the length of lineEnd.
---@param seperatorLength number the length of lineSeperator.
---@param startLength number the length of lineStart.
---@return string lineStr the generated comment divider line.
local function generateCommentLine(
	comment,
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
	lineStr = lineStr .. comment
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

--- Generate a solid divider line.
---@param commentLength number the total length of the comment divider.
---@param languageConfig table the language specific comment divider config.
---@param endLength number the length of lineEnd.
---@param seperatorLength number the length of lineSeperator.
---@param startLength number the length of lineStart.
---@return string lineStr the generated comment divider line.
local function generateSolidLine(commentLength, languageConfig, endLength, seperatorLength, startLength)
	-- Calculate the total seperator length.
	local totalSeperatorLength = commentLength - startLength - endLength - 2
	local seperatorNum = math.floor(totalSeperatorLength / seperatorLength)
	totalSeperatorLength = seperatorNum * seperatorLength
	-- Calculate left and right space.
	local leftSpace = math.floor((commentLength - startLength - endLength - totalSeperatorLength) / 2)
	local rightSpace = math.floor((commentLength - startLength - endLength - totalSeperatorLength + 1) / 2)

	-- Construct the solid line.
	local lineStr = ""
	-- Start.
	lineStr = lineStr .. languageConfig.lineStart
	-- Left space.
	for i = 1, leftSpace do
		lineStr = lineStr .. " "
	end
	-- Seperator.
	for i = 1, seperatorNum do
		lineStr = lineStr .. languageConfig.lineSeperator
	end
	-- Right space.
	for i = 1, rightSpace do
		lineStr = lineStr .. " "
	end
	-- End.
	lineStr = lineStr .. languageConfig.lineEnd
	return lineStr
end

--- Generated a line of comment wrapped with spaces.
---@param comment string current buffer conetnt.
---@param bufLineLength number the length of current buffer line.
---@param commentLength number the total length of the comment divider.
---@param languageConfig table the language specific comment divider config.
---@param endLength number the length of lineEnd.
---@param startLength number the length of lineStart.
---@return string lineStr the generated comment divider line.
local function generateCenteredComment(comment, bufLineLength, commentLength, languageConfig, endLength, startLength)
	-- Calculate left and righ space.
	local leftSpace = math.floor((commentLength - startLength - endLength - bufLineLength) / 2)
	local rightSpace = math.floor((commentLength - startLength - endLength - bufLineLength + 1) / 2)

	-- Construct wrapped line.
	local lineStr = ""
	-- Start.
	lineStr = lineStr .. languageConfig.lineStart
	-- Left space.
	for i = 1, leftSpace do
		lineStr = lineStr .. " "
	end
	-- Buffer line.
	lineStr = lineStr .. comment
	-- Right space.
	for i = 1, rightSpace do
		lineStr = lineStr .. " "
	end
	-- End.
	lineStr = lineStr .. languageConfig.lineEnd
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
	local bufLine = vim.fn.input("Enter the comment here: ")
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
	local lineStr = ""
	if bufLineLength > 0 then
		-- Generate comment divider when bufLineLength > 0.
		lineStr = generateCommentLine(
			bufLine,
			bufLineLength,
			commentLength,
			languageConfig,
			endLength,
			seperatorLength,
			startLength
		)
	else
		lineStr = generateSolidLine(commentLength, languageConfig, endLength, seperatorLength, startLength)
	end

	-- Get current buffer row number.
	local currentRow = vim.api.nvim_win_get_cursor(0)[1]
	-- Insert lines.
	vim.api.nvim_buf_set_lines(0, currentRow, currentRow, false, { lineStr })
end

--- Generate comment box divider.
---@param config table config for comment generator.
commentGenerator.commentBox = function(config)
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
	local bufLine = vim.fn.input("Enter the comment here: ")
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
	-- If the current buffer line is empty, reject the request.
	if bufLineLength == 0 then
		print("Empty line.")
		return
	end

	-- Insert lines.
	local insertLines = {}
	-- Top solid line.
	table.insert(insertLines, generateSolidLine(commentLength, languageConfig, endLength, seperatorLength, startLength))
	-- Wrapped comment.
	table.insert(
		insertLines,
		generateCenteredComment(bufLine, bufLineLength, commentLength, languageConfig, endLength, startLength)
	)
	-- End solid line.
	table.insert(insertLines, generateSolidLine(commentLength, languageConfig, endLength, seperatorLength, startLength))

	-- Get current buffer row number.
	local currentRow = vim.api.nvim_win_get_cursor(0)[1]
	-- Insert lines.
	vim.api.nvim_buf_set_lines(0, currentRow, currentRow, false, insertLines)
end

return commentGenerator
