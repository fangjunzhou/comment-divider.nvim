describe("comment-divider", function()
  local divider
  local original_input
  local original_setreg
  local original_notify
  local clipboard
  local notification
  local messages
  local debug_messages

  before_each(function()
    for name in pairs(package.loaded) do
      if name == "comment-divider" or name:match("^comment%-divider%.") then
        package.loaded[name] = nil
      end
    end
    divider = require("comment-divider")
    divider.setup({ maxLineWidth = 24 })
    vim.cmd("enew!")
    vim.bo.filetype = "cpp"
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "original" })
    vim.api.nvim_win_set_cursor(0, { 1, 0 })
    original_input = vim.ui.input
    original_setreg = vim.fn.setreg
    original_notify = vim.notify
    clipboard = nil
    notification = nil
    vim.fn.setreg = function(register, value)
      clipboard = { register, value }
    end
    messages = {}
    debug_messages = {}
    vim.notify = function(message, level)
      if level == vim.log.levels.DEBUG then
        table.insert(debug_messages, message)
        return
      end
      notification = { message, level }
      table.insert(messages, message)
    end
  end)

  after_each(function()
    vim.ui.input = original_input
    vim.fn.setreg = original_setreg
    vim.notify = original_notify
    vim.cmd("bwipeout!")
  end)

  local function input(text)
    vim.ui.input = function(_, callback)
      callback(text)
    end
  end

  local function lines()
    return vim.api.nvim_buf_get_lines(0, 0, -1, false)
  end

  it("inserts a trimmed centered line", function()
    input("  Hello  ")
    divider.commentLine()
    assert.are.same({ "original", "/* ----- Hello  ----- */" }, lines())
  end)

  it("inserts a solid line for whitespace input", function()
    input("   ")
    divider.commentLine()
    assert.are.same({ "original", "/* ------------------ */" }, lines())
  end)

  it("logs diagnostics at DEBUG without a debug setting", function()
    input("Hello")
    divider.commentLine()
    divider.commentBox()
    assert.are.same({
      "Current file type: cpp",
      "Current buffer line: Hello",
      "Current file type: cpp",
      "Current buffer line: Hello",
    }, debug_messages)
    divider.info()
    assert.is_nil(messages[1]:find("debug", 1, true))
  end)

  it("inserts a three-line box", function()
    input("Hello")
    divider.commentBox()
    assert.are.same({
      "original",
      "/* ------------------ */",
      "/*       Hello        */",
      "/* ------------------ */",
    }, lines())
  end)

  it("cancels either prompt without changing content", function()
    input(nil)
    divider.commentLine()
    assert.are.same({ "original" }, lines())
    divider.commentBox()
    assert.are.same({ "original" }, lines())
  end)

  it("rejects oversized text for lines and boxes", function()
    input(string.rep("x", 24))
    divider.commentLine()
    divider.commentBox()
    assert.are.same({ "original" }, lines())
    assert.are.same({ "Comment too long.", "Comment too long." }, messages)
    assert.are.same({ "Comment too long.", vim.log.levels.ERROR }, notification)
  end)

  it("uses indentation from indentexpr and fills to the maximum line width", function()
    vim.bo.indentexpr = "4"
    vim.bo.autoindent = true
    input("Hello")
    divider.commentLine()
    assert.are.same({ "original", "    /* --- Hello  --- */" }, lines())
    assert.are.equal(24, vim.fn.strdisplaywidth(lines()[2]))
    assert.are.equal(2, vim.api.nvim_win_get_cursor(0)[1])
    divider.commentBox()
    for _, line in ipairs({ lines()[3], lines()[4], lines()[5] }) do
      assert.are.equal(24, vim.fn.strdisplaywidth(line))
      assert.is_truthy(line:match("^    "))
    end
  end)

  it("leaves indented content unchanged when the prompt is canceled", function()
    vim.bo.indentexpr = "4"
    vim.bo.autoindent = true
    input(nil)
    divider.commentLine()
    divider.commentBox()
    assert.are.same({ "original" }, lines())
  end)

  it("measures wide text in display columns", function()
    input("界")
    divider.commentLine()
    assert.are.equal(24, vim.fn.strdisplaywidth(lines()[2]))
  end)

  it("counts tab indentation as display columns and rejects text that will not fit", function()
    vim.bo.expandtab = false
    vim.bo.tabstop = 8
    vim.api.nvim_buf_set_lines(0, 0, -1, false, { "\toriginal" })
    vim.bo.autoindent = true
    input("")
    divider.commentLine()
    assert.are.equal("\t/* ---------- */", lines()[2])
    assert.are.equal(24, vim.fn.strdisplaywidth(lines()[2]))

    input("Too long now")
    divider.commentBox()
    assert.are.same({ "\toriginal", "\t/* ---------- */" }, lines())
    assert.are.same({ "Comment too long.", vim.log.levels.ERROR }, notification)
  end)

  it("uses current names across repeated setup calls", function()
    divider.setup({ maxLineWidth = 26, defaultStyle = { barrierCharacter = "=" } })
    vim.bo.filetype = "unknown"
    input("")
    divider.commentLine()
    assert.are.equal("/* ==================== */", lines()[2])

    divider.setup({ maxLineWidth = 24, defaultStyle = { barrierCharacter = "~" } })
    divider.commentLine()
    assert.are.equal("/* ~~~~~~~~~~~~~~~~~~ */", lines()[3])
    divider.setup({ filetypeStyles = { cpp = { barrierCharacter = "+" } } })
    vim.bo.filetype = "cpp"
    divider.commentLine()
    assert.are.equal("/* ++++++++++++++++++ */", lines()[4])
    divider.setup({ filetypeStyles = { cpp = { barrierCharacter = "=" } } })
    divider.commentLine()
    assert.are.equal("/* ================== */", lines()[5])
  end)

  it("rejects old configuration keys without changing the current configuration", function()
    for _, options in ipairs({
      { commentLength = 12, maxLineWidth = 24 },
      { defaultConfig = { lineStart = "#" } },
      { languageConfig = { cpp = { lineStart = "#" } } },
      { defaultStyle = { lineSeperator = "=" } },
      { filetypeStyles = { cpp = { lineSeperator = "=" } } },
      { debug = false },
      { unknown = true },
    }) do
      local ok, err = pcall(divider.setup, options)
      assert.is_false(ok)
      assert.is_truthy(err:find("Unknown comment-divider option:", 1, true))
    end
    input("")
    divider.commentLine()
    assert.are.equal("/* ------------------ */", lines()[2])
  end)

  it("defaults to 80 display columns", function()
    divider.reload()
    divider = require("comment-divider")
    divider.setup()
    input("")
    divider.commentLine()
    assert.are.equal(80, vim.fn.strdisplaywidth(lines()[2]))
  end)

  it("rejects empty boxes", function()
    input("  ")
    divider.commentBox()
    assert.are.same({ "original" }, lines())
    assert.are.same({ "Empty line." }, messages)
  end)

  it("uses filetype-specific styles", function()
    vim.bo.filetype = "python"
    input("")
    divider.commentLine()
    assert.are.equal("# -------------------- #", lines()[2])
  end)

  it("falls back to the default style", function()
    vim.bo.filetype = "unknown"
    input("")
    divider.commentLine()
    assert.are.equal("/* ------------------ */", lines()[2])
  end)

  it("deep-merges repeated setup calls", function()
    divider.setup({ defaultStyle = { barrierCharacter = "=" } })
    divider.setup({ maxLineWidth = 24 })
    vim.bo.filetype = "unknown"
    input("")
    divider.commentLine()
    assert.are.equal("/* ================== */", lines()[2])
  end)

  it("supports multi-character barriers", function()
    divider.setup({ defaultStyle = { barrierCharacter = "=-" } })
    vim.bo.filetype = "unknown"
    input("Hi")
    divider.commentLine()
    assert.are.equal("/* =-=-=-  Hi  =-=-=- */", lines()[2])
    divider.setup({ maxLineWidth = 25 })
    input("")
    divider.commentLine()
    assert.are.equal("/* =-=-=-=-=-=-=-=-=-  */", lines()[3])
    input("Hi")
    divider.commentBox()
    assert.are.equal("/*         Hi          */", lines()[5])
  end)

  it("registers one command with subcommand completion and dispatches it", function()
    vim.cmd("runtime plugin/comment-divider.lua")
    vim.cmd("runtime plugin/comment-divider.lua")
    local commands = vim.api.nvim_get_commands({})
    assert.is_not_nil(commands.CommentDivider)
    for _, name in ipairs({
      "CommentDividerLine",
      "CommentDividerBox",
      "CommentDividerConfigInfo",
      "CommentDividerFiletype",
    }) do
      assert.is_nil(commands[name])
    end
    assert.are.same({ "box", "filetype", "line", "status" }, vim.fn.getcompletion("CommentDivider ", "cmdline"))
    assert.are.same({ "line" }, vim.fn.getcompletion("CommentDivider l", "cmdline"))
    input("Hello")
    vim.cmd("CommentDivider line")
    assert.are.equal("/* ----- Hello  ----- */", lines()[2])
    vim.cmd("CommentDivider status")
    vim.cmd("CommentDivider filetype")
    assert.is_truthy(messages[1]:find("Current comment divider config:", 1, true))
    assert.are.same({ "+", "cpp" }, clipboard)
    assert.are.same({ "Filetype copied to clipboard: cpp", vim.log.levels.INFO }, notification)
    input("Box")
    vim.cmd("CommentDivider box")
    assert.are.equal(5, #lines())
    vim.cmd("CommentDivider unknown")
    assert.are.same({ "Unknown CommentDivider subcommand: unknown", vim.log.levels.ERROR }, notification)
    assert.are.equal(5, #lines())
  end)

  it("reloads plugin modules without Plenary at runtime", function()
    local previous = divider
    divider.reload()
    assert.is_nil(package.loaded["comment-divider.comment-config"])
    assert.is_nil(package.loaded["comment-divider.comment-generator"])
    assert.are_not.equal(previous, require("comment-divider"))
  end)
end)
