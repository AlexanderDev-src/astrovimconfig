-- One language server per job.
--
-- AstroNvim enables every Mason package that maps to an lspconfig name
-- (AstroNvim/lua/astronvim/plugins/configs/mason-lspconfig.lua), so a server
-- installed once stays enabled even after the pack that pulled it in is gone.
-- That left several servers attaching to the same buffer and reporting the same
-- problems twice. `handlers.<name> = false` stops AstroLSP from enabling one.
--
-- Check what is attached to a buffer with `:LspInfo`, and what is enabled at all
-- with `:lua vim.print(vim.tbl_keys(vim.lsp._enabled_configs))`.

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
    handlers = {
      -- Python: basedpyright (types) + ruff (lint and format) stay enabled.
      -- All three of these are whole-program type checkers that duplicate
      -- basedpyright's diagnostics on every buffer.
      pyright = false, -- basedpyright is a fork of it, with more checks
      pyrefly = false, -- Meta's checker, still alpha
      ty = false, -- Astral's checker, still alpha

      -- SQL: sqls stays enabled. These two only understand one vendor's
      -- dialect and report syntax errors on anything else.
      bqls = false, -- BigQuery
      postgres_lsp = false, -- PostgreSQL

      -- Docker: docker_language_server stays enabled. It covers both
      -- Dockerfiles and compose files, and replaces the two older servers.
      dockerls = false,
      docker_compose_language_service = false,

      -- stylua is a formatter, already wired up through none-ls.
      stylua = false,

      -- codebook is a spell checker that attaches to 21 filetypes and reports
      -- every unrecognised word as a diagnostic. Neovim's own spellcheck is on
      -- <Leader>us.
      codebook = false,
    },

      config = {
        -- clangd writes its whole info-level trace to stderr, and Neovim logs
        -- server stderr at ERROR regardless of the client log level, so every
        -- keystroke ended up in lsp.log (83MB before this). --log=error keeps
        -- real failures and drops the per-request chatter.
        clangd = {
          cmd = { "clangd", "--log=error" },
        },

        -- basedpyright and ruff both flag unused imports and unused locals, so
        -- each one is reported twice. Ruff owns linting (F401, F841); leave
        -- basedpyright on type errors only. Everything else it reports, including
        -- unused parameters and unreachable except clauses, has no ruff
        -- equivalent in the default rule set and stays on.
        basedpyright = {
          -- A directory with its own `.venv` is its own workspace, even below
          -- another project: ~/devsrc/data-sci-year2 has a pyproject.toml, and
          -- sub-projects in it that carry their own uv environment were
          -- otherwise checked against the parent's packages. The inner list
          -- means "whichever of these is nearest".
          root_markers = {
            { "pyrightconfig.json", ".venv" },
            "pyproject.toml",
            "setup.py",
            "setup.cfg",
            "requirements.txt",
            "Pipfile",
            ".git",
          },
          -- basedpyright does not look for a virtual environment itself, and
          -- the community pack points it at whichever `python` is first on
          -- PATH, so every third-party import was "could not be resolved"
          -- unless the environment was activated before starting Neovim. Use
          -- the workspace's own `.venv` when it has one.
          before_init = function(_, config)
            local python = config.root_dir and (config.root_dir .. "/.venv/bin/python")
            if not python or vim.fn.executable(python) == 0 then python = vim.fn.exepath "python" end
            config.settings = config.settings or {}
            config.settings.python = config.settings.python or {}
            config.settings.python.pythonPath = python
          end,
          settings = {
            basedpyright = {
              analysis = {
                diagnosticSeverityOverrides = {
                  reportArgumentType = "none", -- Suppress argument type mismatches, including library stub mismatches.
                  reportUnusedImport = "none", -- ruff F401
                  reportUnusedVariable = "none", -- ruff F841

                  -- basedpyright's own rules on top of pyright, on by default
                  -- in its "recommended" mode. They fire on every value whose
                  -- type comes back Any or partially unknown from an untyped
                  -- library, so one pandas call stacks up several of them and
                  -- buries the real type errors. Off; every other rule still
                  -- catches genuine mismatches.
                  reportAny = "none",
                  reportExplicitAny = "none",
                  reportUnknownArgumentType = "none",
                  reportUnknownLambdaType = "none",
                  reportUnknownMemberType = "none",
                  reportUnknownParameterType = "none",
                  reportUnknownVariableType = "none",
                },
              },
            },
          },
        },
      },
    },
  },

  -- mason-null-ls registers a none-ls source for every installed tool it has a
  -- builtin for. bash-language-server already runs shellcheck itself, so the
  -- none-ls copy reports each finding a second time.
  {
    "jay-babu/mason-null-ls.nvim",
    optional = true,
    opts = function(_, opts)
      opts.handlers = opts.handlers or {}
      opts.handlers.shellcheck = function() end
    end,
  },
}
