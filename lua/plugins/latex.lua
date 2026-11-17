-- LaTeX language servers, next to vimtex (community.lua), which keeps
-- compiling and viewing (<localleader>ll / <localleader>lv).
--
-- texlab: completion, references, rename, document symbols and diagnostics
--         from the build log.
-- ltex_plus: LanguageTool grammar and spelling. It is the maintained fork of
--         ltex-ls (valentjn/ltex-ls stopped at 16.0.0 in 2023) and reads the
--         same `ltex` settings.

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    optional = true,
    opts = function(_, opts)
      opts.ensure_installed =
        require("astrocore").list_insert_unique(opts.ensure_installed, { "texlab", "ltex-ls-plus" })
    end,
  },

  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      config = {
        ltex_plus = {
          -- lspconfig attaches ltex to 19 filetypes, gitcommit, html and
          -- markdown among them. Keep it on LaTeX so it does not flag every
          -- commit message and README (same reason codebook is off in
          -- lsp-servers.lua).
          filetypes = { "tex", "plaintex", "bib" },
          settings = {
            ltex = {
              enabled = { "latex", "tex", "bib", "bibtex", "plaintex" },
              language = "en-US",
            },
          },
        },
      },
    },
  },
}
