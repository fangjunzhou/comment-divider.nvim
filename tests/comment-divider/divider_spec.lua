describe("comment-divider", function()
  local divider
  local original_input
  local original_setreg
  local original_notify
  local clipboard
  local notification
  local messages

  before_each(function()
    for name in pairs(package.loaded) do
      if name == "comment-divider" or name:match("^comment%-divider%.") then
        package.loaded[name] = nil
      end
    end
    divider = require("comment-divider")
    divider.setup({ debug = false, commentLength = 24 })
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
    vim.notify = function(message, level)
      assert.are.equal(vim.log.levels.INFO, level)
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

  it("sends debug messages as info notifications", function()
    divider.setup({ debug = true })
    input("Hello")
    divider.commentLine()
    divider.commentBox()
    assert.are.same({
      "Current file type: cpp",
      "Current buffer line: Hello",
      "Current file type: cpp",
      "Current buffer line: Hello",
    }, messages)
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
    divider.setup({ defaultConfig = { lineSeperator = "=" } })
    divider.setup({ debug = false })
    vim.bo.filetype = "unknown"
    input("")
    divider.commentLine()
    assert.are.equal("/* ================== */", lines()[2])
  end)

  it("supports multibyte-length separator strings", function()
    divider.setup({ defaultConfig = { lineSeperator = "=-" } })
    vim.bo.filetype = "unknown"
    input("Hi")
    divider.commentLine()
    assert.are.equal(24, #lines()[2])
    assert.is_truthy(lines()[2]:find("Hi", 1, true))
  end)

  it("registers commands once and dispatches them", function()
    vim.cmd("runtime plugin/comment-divider.lua")
    vim.cmd("runtime plugin/comment-divider.lua")
    input("Hello")
    vim.cmd("CommentDividerLine")
    assert.are.equal("/* ----- Hello  ----- */", lines()[2])
    vim.cmd("CommentDividerConfigInfo")
    vim.cmd("CommentDividerFiletype")
    assert.is_truthy(messages[1]:find("Current comment divider config:", 1, true))
    assert.are.same({ "+", "cpp" }, clipboard)
    assert.are.same({ "Filetype copied to clipboard: cpp", vim.log.levels.INFO }, notification)
    input("Box")
    vim.cmd("CommentDividerBox")
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
