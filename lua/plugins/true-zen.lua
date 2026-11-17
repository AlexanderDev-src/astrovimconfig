-- true-zen.nvim comes from community.lua (maps under <Leader>z). This file
-- cleans up the Ataraxis padding windows and fixes the option restore on
-- Neovim 0.12.
--
-- Ataraxis centers the file by opening empty padding windows on all four sides.
-- Heirline gives each one AstroNvim's winbar, which labels a buffer with no name
-- "Untitled", because the winbar is set before true-zen marks the buffer
-- `nofile`. The top and bottom windows are made even when their padding is 0:
-- they are one line high and show a "[Scratch] [-]" status line and the file
-- path under the text. `open_pos` clears the winbars and closes those windows.
--
-- Minimalist mode (also run by Ataraxis and Narrow) saves each option it hides
-- with `fn.gettabwinvar`, which gives booleans back as 0/1, and converts them
-- with `opt == 1 and true or false or opt`. A boolean that was off comes back
-- as the number 0 (showmode is off in AstroNvim), and a number option set to 1
-- comes back as `true`. Neovim 0.12 type-checks `vim.o`, so leaving the mode
-- fails with "Invalid value for option 'showmode': expected boolean, got number
-- 0" and the statusline and line numbers stay hidden.
--
-- Upstream PR #143 fixes save_opts, but it is still open. save_opts is local,
-- so this wraps `off` and fixes the saved table's types before it is restored.
-- Once the PR lands, every value already has the right type and the wrapper
-- changes nothing.

-- the "row" or "col" node of `vim.fn.winlayout()` that holds window `winid`
local function parent_node(node, winid)
  if node[1] == "leaf" then return nil end
  for _, child in ipairs(node[2]) do
    if child[1] == "leaf" and child[2] == winid then return node end
    local found = parent_node(child, winid)
    if found then return found end
  end
end

local function clean_ataraxis()
  local main = vim.api.nvim_get_current_win()

  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    if vim.w[win].tz_pad_win then vim.api.nvim_set_option_value("winbar", "", { scope = "local", win = win }) end
  end

  -- the top and bottom windows sit above and below the main window in its column
  local column = parent_node(vim.fn.winlayout(), main)
  if not column or column[1] ~= "col" then return end
  local padding = require("true-zen.config").options.modes.ataraxis.padding
  local side = "top"
  for _, child in ipairs(column[2]) do
    local win = child[2]
    if win == main then
      side = "bottom"
    elseif child[1] == "leaf" and vim.w[win].tz_pad_win and padding[side] == 0 then
      vim.api.nvim_win_close(win, true)
    end
  end
end

---@type LazySpec
return {
  "Pocco81/true-zen.nvim",
  opts = {
    modes = {
      ataraxis = {
        callbacks = { open_pos = clean_ataraxis },
      },
    },
  },
  config = function(_, opts)
    require("true-zen").setup(opts)

    -- required after setup: the module keeps a reference to the options table
    -- that setup replaces
    local minimalist = require "true-zen.minimalist"
    local original_off = minimalist.off

    local saved
    for i = 1, math.huge do
      local name, value = debug.getupvalue(original_off, i)
      if name == nil then break end
      if name == "original_opts" then
        saved = value
        break
      end
    end
    if not saved then return end -- upstream code changed, nothing to fix

    minimalist.off = function(...)
      for name, value in pairs(saved) do
        local info = name ~= "highlights" and vim.api.nvim_get_option_info2(name, {})
        if info and info.type == "boolean" and type(value) == "number" then
          saved[name] = value == 1
        elseif info and info.type == "number" and type(value) == "boolean" then
          saved[name] = value and 1 or 0
        end
      end
      return original_off(...)
    end
  end,
}
