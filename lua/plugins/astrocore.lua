-- AstroCore provides a central place to modify mappings, vim options, autocommands, and more!
-- Configuration documentation can be found with `:h astrocore`
-- NOTE: We highly recommend setting up the Lua Language Server (`:LspInstall lua_ls`)
--       as this provides autocomplete and documentation while editing

-- Virtual lines never soft-wrap (Neovim draws them with virt_lines_overflow =
-- "scroll"), but they do split a message on "\n", so long messages get broken
-- to fit the window here. Lines that already fit keep their indentation.
-- shortcut: the width is read when diagnostics render, so after a window
-- resize the wrap updates on the next diagnostic refresh; a single word wider
-- than the space left (a long path) still runs past the edge.
local function wrap_virtual_line(diagnostic)
  local msg = diagnostic.message
  if diagnostic.code then msg = ("%s: %s"):format(diagnostic.code, msg) end
  local win = vim.fn.bufwinid(diagnostic.bufnr)
  if win == -1 then win = vim.api.nvim_get_current_win() end
  local info = vim.fn.getwininfo(win)[1]
  -- the message starts after the diagnostic's column and the 6-cell "└──── "
  local width = math.max(20, info.width - info.textoff - diagnostic.col - 6)

  local lines = {}
  for para in (msg .. "\n"):gmatch "(.-)\n" do
    if vim.fn.strdisplaywidth(para) <= width then
      table.insert(lines, para)
    else
      local line = ""
      for word in para:gmatch "%S+" do
        if line ~= "" and vim.fn.strdisplaywidth(line .. " " .. word) > width then
          table.insert(lines, line)
          line = word
        else
          line = line == "" and word or line .. " " .. word
        end
      end
      table.insert(lines, line)
    end
  end
  return table.concat(lines, "\n")
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    -- Configure core features of AstroNvim
    features = {
      large_buf = {
        size = 1024 * 256,
        lines = 10000,
        -- notebook size on disk is mostly base64 images; the buffer only holds the code
        enabled = function(bufnr) return not vim.api.nvim_buf_get_name(bufnr):match "%.ipynb$" end,
      }, -- set global limits for large files for disabling features like treesitter
      autopairs = true, -- enable autopairs at start
      cmp = true, -- enable completion at start
      -- Diagnostics render as virtual lines below the code, not as virtual text
      -- at the end of it. Toggle with <Leader>uV and <Leader>uv respectively.
      diagnostics = { virtual_text = false, virtual_lines = true }, -- diagnostic settings on startup
      highlighturl = true, -- highlight URLs at start
      notifications = true, -- enable notifications at start
    },
    -- Diagnostics configuration (for vim.diagnostics.config({...})) when diagnostics are on
    diagnostics = {
      virtual_text = false,
      -- rust-analyzer turns each rustc `help:` and `note:` into its own hint at
      -- the same spot, so every warning showed twice. Hints stay in the float (gl).
      virtual_lines = { severity = { min = vim.diagnostic.severity.INFO }, format = wrap_virtual_line },
      underline = true,
    },
    -- passed to `vim.filetype.add` -- see `:h vim.filetype.add` for usage
    -- filetypes = {
    --   extension = { foo = "fooscript" },
    --   filename = { [".foorc"] = "fooscript" },
    --   pattern = { [".*/etc/foo/.*"] = "fooscript" },
    -- },
    -- vim options can be configured here
    options = {
      opt = { -- vim.opt.<key>
        relativenumber = true, -- sets vim.opt.relativenumber
        number = true, -- sets vim.opt.number
        spell = false, -- sets vim.opt.spell
        signcolumn = "yes", -- sets vim.opt.signcolumn to yes
        wrap = true, -- soft-wrap long lines at the window edge (AstroNvim already sets linebreak + breakindent)
        expandtab = true, -- use spaces instead of tab characters
        tabstop = 4, -- a tab renders as 4 columns
        softtabstop = 4, -- <Tab>/<BS> move by 4 columns
        shiftwidth = 4, -- one indent level (>> and auto-indent) is 4 columns
      },
      g = { -- vim.g.<key>
        -- configure global vim variables (vim.g)
        -- NOTE: `mapleader` and `maplocalleader` must be set in the AstroNvim opts or before `lazy.setup`
        -- This can be found in the `lua/lazy_setup.lua` file
      },
    },
    -- Mappings can be configured through AstroCore as well.
    -- NOTE: keycodes follow the casing in the vimdocs. For example, `<Leader>` must be capitalized
    mappings = {
      -- first key is the mode
      n = {
        -- second key is the lefthand side of the map

        -- navigate buffer tabs
        ["]b"] = { function() require("astrocore.buffer").nav(vim.v.count1) end, desc = "Next buffer" },
        ["[b"] = { function() require("astrocore.buffer").nav(-vim.v.count1) end, desc = "Previous buffer" },

        -- mappings seen under group name "Buffer"
        ["<Leader>bd"] = {
          function()
            require("astroui.status.heirline").buffer_picker(
              function(bufnr) require("astrocore.buffer").close(bufnr) end
            )
          end,
          desc = "Close buffer from tabline",
        },

        -- tables with just a `desc` key will be registered with which-key if it's installed
        -- this is useful for naming menus
        -- ["<Leader>b"] = { desc = "Buffers" },

        -- setting a mapping to false will disable it
        -- ["<C-S>"] = false,

        -- count-aware terminal splits: `2<Leader>tv` opens/toggles terminal #2
        ["<Leader>tv"] = {
          '<Cmd>execute v:count1 . "ToggleTerm size=80 direction=vertical"<CR>',
          desc = "ToggleTerm vertical split",
        },
        ["<Leader>th"] = {
          '<Cmd>execute v:count1 . "ToggleTerm size=10 direction=horizontal"<CR>',
          desc = "ToggleTerm horizontal split",
        },
      },
    },
  },
}
