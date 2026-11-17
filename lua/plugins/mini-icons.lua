-- Icon provider for neo-tree, blink.cmp, and anything mocking nvim-web-devicons.
-- AstroNvim wires this into neo-tree's icon provider, so changes here show up in the file tree.
--
-- Live testing inside nvim:
--   :lua vim.print({ MiniIcons.get("file", "tasks.db") })  -- 3rd value true = generic fallback
--   :lua vim.print(MiniIcons.list("extension"))            -- every known name
--   :Lazy reload mini.icons | Neotree close | Neotree      -- apply this file and redraw
--
-- Only names that fall back to the generic glyph are worth listing here; mini.icons
-- already covers src, tests, docs, .git, .gitignore, Cargo.toml/.lock, *.rs, *.lua, *.sql.

---@type LazySpec
return {
  "nvim-mini/mini.icons",
  opts = {
    style = "glyph", -- "glyph" or "ascii"

    -- Matched against the full file name (highest priority)
    file = {
      [".env"] = { glyph = "󰒓", hl = "MiniIconsYellow" },
      [".env.local"] = { glyph = "󰒓", hl = "MiniIconsYellow" },
      [".env.example"] = { glyph = "󰒓", hl = "MiniIconsGrey" },
    },

    -- Matched against the file extension
    extension = {
      db = { glyph = "󰆼", hl = "MiniIconsGreen" },
      sqlite = { glyph = "󰆼", hl = "MiniIconsGreen" },
      sqlite3 = { glyph = "󰆼", hl = "MiniIconsGreen" },
    },

    -- Matched against the directory name. Keep these folder-shaped so the tree
    -- still reads as a tree; mini.icons follows the same rule for its own set.
    directory = {
      migrations = { glyph = "󰉋", hl = "MiniIconsGreen" },
      target = { glyph = "󱧼", hl = "MiniIconsGrey" }, -- same glyph mini uses for "build"
      data = { glyph = "󰉋", hl = "MiniIconsGreen" },
      api = { glyph = "󰉋", hl = "MiniIconsCyan" },
      handlers = { glyph = "󰉋", hl = "MiniIconsCyan" },
      models = { glyph = "󰉋", hl = "MiniIconsPurple" },
      config = { glyph = "󰉋", hl = "MiniIconsYellow" },
    },

    -- Matched against the filetype (used when the extension gives no answer)
    filetype = {},

    -- LSP kinds, used in the completion menu
    lsp = {},

    -- Fallback per category when nothing above matches
    default = {},
  },
}
