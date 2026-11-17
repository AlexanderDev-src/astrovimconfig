-- Same rules as catppuccin.lua: color says what it is, bold = definition,
-- italic (cursive in Maple Mono) = comment, keyword, parameter, self/this.
-- Colorschemes: onedark, onedark_vivid, onedark_dark, onelight, vaporwave

---@type LazySpec
return {
  "olimorris/onedarkpro.nvim",
  lazy = true,
  opts = {
    styles = {
      comments = "italic",
      keywords = "italic",
      conditionals = "italic",
      parameters = "italic",
    },
    highlights = {
      -- definitions bold, calls plain
      ["@function"] = { fg = "${blue}", bold = true },
      ["@function.method"] = { fg = "${blue}", bold = true },
      ["@function.call"] = { fg = "${blue}" },
      ["@function.method.call"] = { fg = "${blue}" },
      -- onedark paints every variable red like parameters; keep plain ones plain
      -- so a red italic name always means "parameter"
      ["@variable"] = { fg = "${fg}" },
      ["@variable.builtin"] = { italic = true, extend = true }, -- self, this

      -- LSP tokens follow the same rules
      ["@lsp.type.function"] = { link = "@function.call" },
      ["@lsp.type.method"] = { link = "@function.method.call" },
      ["@lsp.type.parameter"] = { link = "@variable.parameter" },
      ["@lsp.typemod.function.declaration"] = { link = "@function" },
      ["@lsp.typemod.method.declaration"] = { link = "@function.method" },
      ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" }, -- rust-analyzer
    },
  },
}
