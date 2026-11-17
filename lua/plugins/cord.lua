-- Discord Rich Presence (cord.nvim v2)
-- Overrides the defaults from astrocommunity.media.cord-nvim

-- Keys are Neovim filetypes (`:set ft?`), not file extensions.
local jokes = {
  -- systems
  c = "Chasing a segfault in ",
  cpp = "Decoding 300 lines of template errors in ",
  rust = "Fighting the borrow checker in ",
  go = "Typing `if err != nil` for the 400th time in ",
  zig = "Passing an allocator to literally everything in ",
  asm = "Talking directly to the CPU in ",

  -- JVM / .NET / mobile
  java = "Writing AbstractSingletonProxyFactoryBean in ",
  kotlin = "Adding !! until it compiles in ",
  scala = "Waiting for sbt to resolve dependencies in ",
  cs = "Adding one more layer of async Task<> in ",
  swift = "Waiting for Xcode to finish indexing in ",
  dart = "Wrapping a widget in a widget in a widget in ",

  -- scripting
  python = "Fixing indentation errors in ",
  ruby = "Monkey-patching String in ",
  php = "Insisting modern PHP is actually fine in ",
  perl = "Writing code that looks like line noise in ",
  lua = "Counting arrays from 1 in ",
  vim = "Writing Vimscript like it's 1998 in ",
  r = "Arguing data.frame vs tibble in ",
  julia = "Waiting for time-to-first-plot in ",
  matlab = "Paying for a license to multiply matrices in ",

  -- functional
  haskell = "Explaining monads to nobody in ",
  ocaml = "Pattern-matching my way out of problems in ",
  elixir = "Letting it crash, on purpose, in ",
  erlang = "Counting commas, semicolons and periods in ",
  clojure = "Balancing parentheses in ",

  -- web
  javascript = "Figuring out why [] + {} is a string in ",
  typescript = "Casting everything to `any` in ",
  javascriptreact = "Fixing an infinite useEffect loop in ",
  typescriptreact = "Typing props for a component that renders one div in ",
  html = "Nesting a div in a div in a div in ",
  css = "Trying to center a div in ",
  scss = "Nesting selectors 9 levels deep in ",
  vue = "Arguing Options API vs Composition API in ",
  svelte = "Explaining what Svelte is to everyone in ",

  -- shells
  sh = "Forgetting the spaces inside [ ] in ",
  bash = "Quoting variables until they stop word-splitting in ",
  zsh = "Tweaking the prompt instead of working in ",
  fish = "Pasting bash snippets that don't work in ",

  -- documents
  tex = "Moving one figure and breaking three pages in ",
  plaintex = "Hand-tuning \\hspace in ",
  bib = "Fixing a BibTeX entry that compiled yesterday in ",
  markdown = "Writing docs nobody will read in ",

  -- data / config / build
  sql = "Forgetting the WHERE on a DELETE in ",
  json = "Hunting a trailing comma in ",
  yaml = "Debugging invisible whitespace in ",
  toml = "Configuring the thing that configures things in ",
  dockerfile = "Rebuilding a 2 GB image for a one-line change in ",
  make = "Replacing spaces with tabs in ",
  cmake = "Asking why CMake found the wrong library in ",
  nix = "Rebuilding the universe in ",
  gitcommit = "Writing 'fix stuff' in ",
}

local function joke_for(ft) return jokes[ft] or "Creating new bugs in " end

local uv = vim.uv or vim.loop
local idle_since, idle_refresh = nil, nil

local IDLE_TIMEOUT_MIN = 10
local function idle_stage()
  -- idle_since คือเวลาที่ cord เข้าโหมด idle (หลัง timeout) เลยบวกเวลา timeout กลับเข้าไป
  local mins = idle_since and ((uv.now() - idle_since) / 60000 + IDLE_TIMEOUT_MIN) or IDLE_TIMEOUT_MIN
  if mins >= 60 then return "I miss grass. Grass doesn't miss me.", "🌱 It's been a while" end
  if mins >= 30 then return "Opened 1 tab to research. Now at 47.", "🐇 Down the rabbit hole" end
  return "Brain.exe has stopped responding", "Have you tried turning me off and on again?"
end

local function stop_refresh()
  if idle_refresh then
    idle_refresh:stop()
    idle_refresh:close()
    idle_refresh = nil
  end
  idle_since = nil
end

---@type LazySpec
return {
  "vyfor/cord.nvim",
  ---@type CordConfig
  opts = {
    editor = {
      client = "1566624116096897034", -- 'vim'|'neovim'|'lunarvim'|'nvchad'|'astronvim'|'lazyvim' or a Discord application ID
      tooltip = "404: motivation not found",
      icon = "1_prism_2x",
    },
    display = {
      theme = "void", -- 'default'|'atom'|'catppuccin'|'minecraft'|'void'|'classic'
      flavor = "accent", -- 'dark'|'light'|'accent'
      view = "full", -- 'full'|'editor'|'asset'|'auto'
      swap_fields = false,
      swap_icons = false,
    },
    timestamp = {
      enabled = true,
      reset_on_idle = false,
      reset_on_change = false,
    },
    idle = {
      enabled = true,
      timeout = IDLE_TIMEOUT_MIN * 60000,
      show_status = true,
      details = function() return (idle_stage()) end,
      tooltip = function() return select(2, idle_stage()) end,
    },
    -- cord only pushes the idle presence once, so re-send it every 30s to let
    -- the text move through the 1 / 5 / 10 minute stages.
    hooks = {
      idle_enter = function(opts)
        if idle_refresh then return end
        local mgr = opts.manager
        idle_since = uv.now()
        idle_refresh = uv.new_timer()
        idle_refresh:start(
          30000,
          30000,
          vim.schedule_wrap(function()
            if not mgr.idle_timer.is_idle then return stop_refresh() end
            mgr:idle()
          end)
        )
      end,
      idle_leave = stop_refresh,
    },
    -- Activity text. Each entry is a string or a function receiving `opts`
    -- (filename, filetype, workspace, repo_url, cursor_line, cursor_char, ...)
    text = {
      workspace = function(opts) return "Pretending to be productive in " .. opts.workspace end,
      viewing = function(opts) return "Staring at " .. opts.filename .. " hoping it fixes itself" end,
      editing = function(opts) return joke_for(opts.filetype) .. opts.filename end,
      terminal = function(opts) return "Typing random commands in " .. opts.name end,
      dashboard = "Still trying to exit Vim",
    },
    -- Up to 2 buttons
    buttons = {
      { label = "View Repository", url = function(opts) return opts.repo_url end },
    },
    advanced = {
      workspace = {
        root_markers = { ".git", ".hg", ".svn" },
      },
    },
  },
}
