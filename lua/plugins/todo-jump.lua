-- ]T / [T from AstroNvim stop at the end of the buffer. These carry on into the
-- next or previous file under the cwd that has a todo comment, in both
-- directions. Files are found with rg on disk, but the jump inside a file reads
-- the buffer, so notebook.nvim's rendered .ipynb lines are hit, not the line
-- numbers of the JSON on disk.

-- { row, col } of every todo comment in the current buffer, top to bottom
local function todo_positions()
  -- a real number, not 0: is_comment falls back to bufwinid(buf) before
  -- treesitter attaches to a freshly opened file, and bufwinid(0) is -1
  local buf = vim.api.nvim_get_current_buf()
  local config = require "todo-comments.config"
  local highlight = require "todo-comments.highlight"
  local positions = {}
  for row, line in ipairs(vim.api.nvim_buf_get_lines(buf, 0, -1, false)) do
    local ok, start, _, kw = pcall(highlight.match, line)
    -- same rule as todo-comments' own jump: skip only what is known not to be a comment
    local not_comment = ok and start and config.options.highlight.comments_only
      and highlight.is_comment(buf, row - 1, start) == false
    if ok and kw and not not_comment then table.insert(positions, { row, start - 1 }) end
  end
  return positions
end

-- absolute paths of the files under the cwd with a todo comment, sorted
local function todo_files()
  local config = require "todo-comments.config"
  local pattern = config.search_regex(vim.tbl_keys(config.keywords))
  local files = vim.fn.systemlist { config.options.search.command, "--files-with-matches", "--", pattern }
  if vim.v.shell_error ~= 0 then return {} end -- rg exits 1 when nothing matches
  files = vim.tbl_map(function(file) return vim.fn.fnamemodify(file, ":p") end, files)
  table.sort(files)
  return files
end

local function jump(up)
  require "todo-comments" -- loads the plugin and its config

  local row = vim.api.nvim_win_get_cursor(0)[1]
  local positions = todo_positions()
  for i = up and #positions or 1, up and 1 or #positions, up and -1 or 1 do
    local pos = positions[i]
    if (up and pos[1] < row) or (not up and pos[1] > row) then
      vim.api.nvim_win_set_cursor(0, pos)
      return
    end
  end

  local here = vim.api.nvim_buf_get_name(0)
  local files = todo_files()
  for i = up and #files or 1, up and 1 or #files, up and -1 or 1 do
    local file = files[i]
    if (up and file < here) or (not up and file > here) then
      local ok, err = pcall(vim.cmd.edit, vim.fn.fnameescape(file))
      if not ok then
        vim.notify(err, vim.log.levels.ERROR)
        return
      end
      positions = todo_positions()
      if #positions > 0 then
        vim.api.nvim_win_set_cursor(0, positions[up and #positions or 1])
        return
      end
    end
  end
  vim.notify("No more todo comments to jump to", vim.log.levels.WARN)
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    mappings = {
      n = {
        ["]T"] = { function() jump(false) end, desc = "Next TODO comment (across files)" },
        ["[T"] = { function() jump(true) end, desc = "Previous TODO comment (across files)" },
      },
    },
  },
}
