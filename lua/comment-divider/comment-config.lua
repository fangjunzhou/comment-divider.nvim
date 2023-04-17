local commentConfig = {
	debug = true,
	commentLength = 64,
	defaultConfig = {
		lineStart = "/*",
		lineSeperator = "-",
		lineEnd = "*/",
	},
	languageConfig = {
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

return commentConfig
