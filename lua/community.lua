-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.colorscheme.catppuccin" },
  -- indent guides come from snacks.indent (AstroNvim default)
  { import = "astrocommunity.indent.indent-tools-nvim" },
  { import = "astrocommunity.editing-support.multiple-cursors-nvim" },
  { import = "astrocommunity.editing-support.todo-comments-nvim" },
  { import = "astrocommunity.editing-support.dial-nvim" },
  { import = "astrocommunity.editing-support.comment-box-nvim" },
  { import = "astrocommunity.editing-support.cloak-nvim" },
  { import = "astrocommunity.editing-support.rustowl" },
  { import = "astrocommunity.editing-support.refactoring-nvim" },
  -- { import = "astrocommunity.indent.indent-rainbowline" },
  { import = "astrocommunity.recipes.picker-nvchad-theme" },
  { import = "astrocommunity.motion.flash-nvim" },
  { import = "astrocommunity.git.gitgraph-nvim" },
  { import = "astrocommunity.remote-development.nvim-sftp-sync" },
  { import = "astrocommunity.remote-development.remote-sshfs-nvim" },
  { import = "astrocommunity.terminal-integration.toggleterm-manager-nvim" },
  -- { import = "astrocommunity.diagnostics.lsp_lines-nvim" },
  { import = "astrocommunity.git.nvim-tinygit" },
  -- { import = "astrocommunity.workflow.precognition-nvim" },
  -- { import = "astrocommunity.utility.telescope-live-grep-args-nvim" },
  { import = "astrocommunity.editing-support.vim-move" },
  { import = "astrocommunity.editing-support.cutlass-nvim" },
  { import = "astrocommunity.split-and-window.neominimap-nvim" },
  { import = "astrocommunity.game.leetcode-nvim" },
  { import = "astrocommunity.docker.lazydocker" },
  { import = "astrocommunity.syntax.vim-sandwich" },
  { import = "astrocommunity.media.codesnap-nvim" },
  { import = "astrocommunity.media.cord-nvim" },

  { import = "astrocommunity.media.pets-nvim" },
  -- { import = "astrocommunity.note-taking.venn-nvim" },
  -- { import = "astrocommunity.note-taking.neorg" },
  { import = "astrocommunity.programming-language-support.rest-nvim" },
  -- { import = "astrocommunity.editing-support.nvim-treesitter-context" },
  -- { import = "astrocommunity.editing-support.nvim-treesitter-endwise" },
  { import = "astrocommunity.recipes.neovide" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.blade" },
  { import = "astrocommunity.pack.bash" },
  -- Import the Python sub-packs individually: `astrocommunity.pack.python`
  -- makes lazy walk the whole directory, which also pulls in the pyrefly and
  -- ty language servers on top of basedpyright.
  { import = "astrocommunity.pack.python.base" },
  { import = "astrocommunity.pack.python.basedpyright" },
  { import = "astrocommunity.pack.python.ruff" },
  { import = "astrocommunity.pack.php" },
  { import = "astrocommunity.pack.go" },
  { import = "astrocommunity.pack.fish" },
  { import = "astrocommunity.pack.html-css" },
  { import = "astrocommunity.pack.sql" },
  -- :DBUI database client (Oracle, Postgres, SQLite...); Oracle needs `sql` (SQLcl) on PATH
  { import = "astrocommunity.pack.full-dadbod" },
  { import = "astrocommunity.pack.toml" },
  { import = "astrocommunity.pack.tailwindcss" },
  { import = "astrocommunity.pack.typescript" },
  { import = "astrocommunity.pack.json" },
  { import = "astrocommunity.pack.cpp" },
  { import = "astrocommunity.pack.cmake" },
  { import = "astrocommunity.pack.docker" },
  { import = "astrocommunity.pack.prisma" },
  { import = "astrocommunity.pack.java" },

  { import = "astrocommunity.pack.cs-omnisharp" },
  { import = "astrocommunity.pack.hyprlang" },
  { import = "astrocommunity.lsp.dev-tools-nvim" },

  { import = "astrocommunity.quickfix.quicker-nvim" },
  { import = "astrocommunity.markdown-and-latex.vimtex" },

  -- distraction-free writing, maps under <Leader>z (focus, minimalist, ataraxis, narrow)
  { import = "astrocommunity.editing-support.true-zen-nvim" },

  -- floating `:` cmdline popup near the top of the screen
  { import = "astrocommunity.utility.noice-nvim" },

  -- :DiffviewOpen, :DiffviewFileHistory %
  { import = "astrocommunity.git.diffview-nvim" },
  -- project search and replace, maps under <Leader>s
  { import = "astrocommunity.search.grug-far-nvim" },
  -- test runner, maps under <Leader>T; rust, go, python and typescript packs add their adapters
  { import = "astrocommunity.test.neotest" },
  -- edit a directory like a buffer, <Leader>O
  { import = "astrocommunity.file-explorer.oil-nvim" },
  -- task runner (cargo, make, gradle), maps under <Leader>M
  { import = "astrocommunity.code-runner.overseer-nvim" },
  { import = "astrocommunity.markdown-and-latex.render-markdown-nvim" },
  -- live preview for <Leader>lr
  { import = "astrocommunity.lsp.inc-rename-nvim" },
  -- inlay hints at the end of the line, settings in plugins/inlay-hints.lua
  { import = "astrocommunity.lsp.nvim-lsp-endhints" },

  -- { import = "astrocommunity.recipes.picker-nvchad-theme" },
  {
    "mfussenegger/nvim-jdtls",
    opts = {
      settings = {
        java = {
          configuration = {
            runtimes = {
              {
                name = "JavaSE-11",
                path = "/usr/lib/jvm/java-11-openjdk/",
              },
              {
                name = "JavaSE-17",
                path = "/usr/lib/jvm/java-17-openjdk/",
              },
              {
                name = "JavaSE-21",
                path = "/usr/lib/jvm/java-21-openjdk/",
              },
            },
          },

          cleanup = {
            actionsOnSave = {
              "invertEquals",
              "addOverride",
              "addDeprecated",
              -- "addFinalModifier",
              -- "qualifyMembers",
              -- "qualifyStaticMembers",
              -- "stringConcatToTextBlock",
              -- "instanceofPatternMatch",
              -- "lambdaExpression",
              -- "switchExpression",
            },
          },
          codeGeneration = {
            tostring = {
              skipNullValues = true,
              listArrayContents = true,
              template = "${object.className}{${member.name()}=${member.value}, ${otherMembers}}",
            },
            useBlocks = true,
            hashCodeEquals = {
              useInstanceof = true,
              useJava7Objects = true,
            },
            generateComments = false,
            insertLocation = true,
          },
        },
        format = {
          enabled = true,
          settings = {
            url = "https://raw.githubusercontent.com/google/styleguide/gh-pages/eclipse-java-google-style.xml",
            profile = "GoogleStyle",
          },
        },
      },
    },
  },
}
