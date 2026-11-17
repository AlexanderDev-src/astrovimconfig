-- Fixes for astrocommunity.pack.sql

---@type LazySpec
return {
  -- sqls.nvim dropped `require('sqls').on_attach` and now ships an `lsp/sqls.lua`
  -- runtime file that Neovim 0.11+ picks up on its own, buffer commands included.
  -- The pack still calls the old API from an LspAttach autocmd, which throws
  -- "module 'sqls' not found" on every .sql buffer, so disable that autocmd.
  {
    "AstroNvim/astrocore",
    opts = {
      autocmds = {
        sqls_attach = false,
        -- The tree-sitter sql grammar has no Oracle syntax (GRANT, IDENTIFIED, QUOTA,
        -- TABLESPACE...), so those words get no colour. Turn the classic regex syntax
        -- on under it; tree-sitter wins where it has a capture, regex fills the gaps.
        sql_regex_syntax = {
          {
            event = "FileType",
            pattern = { "sql", "mysql", "plsql" },
            callback = function(args)
              vim.schedule(function()
                if vim.api.nvim_buf_is_valid(args.buf) then vim.bo[args.buf].syntax = "sql" end
              end)
            end,
          },
        },
      },
      options = {
        g = {
          sql_type_default = "sqloracle",
          -- dadbod completion needs a DB to read table and column names from.
          -- Export ORACLE_URL (oracle://user:pass@host/service) before starting nvim;
          -- keeping the password out of this file.
          db = vim.env.ORACLE_URL,
        },
      },
    },
  },

  -- sqlfluff requires a mandatory `--dialect` argument. The pack registers it with
  -- none-ls without one, so every .sql buffer reports:
  --   User Error: No dialect was specified.
  --
  -- The dialect below is the fallback. A `.sqlfluff` file in the project takes
  -- precedence, and `vim.g.sqlfluff_dialect` overrides the fallback per session.
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.handlers = opts.handlers or {}
      opts.handlers.sqlfluff = function()
        local null_ls = require "null-ls"
        local dialect = function() return { "--dialect", vim.g.sqlfluff_dialect or "oracle" } end
        -- Style-only rules (case, spacing, indent) buried real errors under ~27 warnings.
        local lint = function()
          return { "--dialect", vim.g.sqlfluff_dialect or "oracle", "--exclude-rules", "LT01,LT02,CP01,CP02,RF04" }
        end
        null_ls.register(null_ls.builtins.diagnostics.sqlfluff.with { extra_args = lint })
        null_ls.register(null_ls.builtins.formatting.sqlfluff.with { extra_args = dialect })
      end
    end,
  },

  -- full-dadbod sets sql sources to { snippets, dadbod, buffer }, which drops lsp,
  -- so sqls keyword completion (SELECT, FROM...) never shows. Put lsp and path back.
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      local sources = { "lsp", "path", "oravim", "snippets", "dadbod", "buffer" }
      opts.sources = opts.sources or {}
      opts.sources.per_filetype = opts.sources.per_filetype or {}
      for _, ft in ipairs { "sql", "mysql", "plsql" } do
        opts.sources.per_filetype[ft] = sources
      end
    end,
  },
}
