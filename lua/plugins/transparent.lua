-- Make ANY colorscheme transparent by clearing the background of core highlight
-- groups. This runs on every `ColorScheme` event, so it re-applies automatically
-- whenever you switch themes (catppuccin, rose-pine, monochrome, ...).

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    autocmds = {
      transparent_background = {
        {
          event = "ColorScheme",
          desc = "Clear backgrounds to make the active colorscheme transparent",
          callback = function()
            -- Highlight groups whose background should become transparent.
            local groups = {
              "Normal",
              "NormalNC",
              "NormalFloat",
              "FloatBorder",
              "FloatTitle",
              "SignColumn",
              "LineNr",
              "CursorLineNr",
              "FoldColumn",
              "EndOfBuffer",
              "MsgArea",
              "StatusLine",
              "StatusLineNC",
              "TabLine",
              "TabLineFill",
              "WinBar",
              "WinBarNC",
              -- popup menu / completion
              "Pmenu",
              "PmenuSbar",
              "NormalSB",
              -- tree / telescope / which-key
              "NeoTreeNormal",
              "NeoTreeNormalNC",
              "NeoTreeEndOfBuffer",
              "TelescopeNormal",
              "TelescopeBorder",
              "WhichKeyFloat",
            }
            for _, group in ipairs(groups) do
              -- nvim_set_hl replaces the whole group; keep fg and the rest, drop bg
              local hl = vim.api.nvim_get_hl(0, { name = group, link = false })
              hl.bg, hl.ctermbg = nil, nil
              vim.api.nvim_set_hl(0, group, hl)
            end
          end,
        },
      },
    },
  },
}
