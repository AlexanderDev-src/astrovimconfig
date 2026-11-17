-- Automatically change the working directory to the project root of the file
-- being edited, so `nvim ~/some/deep/path/code.c` opens neo-tree at the project
-- root instead of wherever the shell happened to be.
--
-- The dotfiles repo is `~/.git`, meaning $HOME itself is a git repository. The
-- stock `.git` detector therefore roots every config file at $HOME and dumps the
-- entire home directory into neo-tree. The detectors below work around that.

local function rooter() return require "astrocore.rooter" end

--- Root picked by hand in neo-tree with `.` or `<BS>` (stored by the command
--- overrides in neo-tree.lua). Detection runs again on every BufEnter, so
--- without this the tree jumps straight back to the detected root as soon as
--- the cursor returns to a file. Only applies to files below the picked
--- directory; anything outside it is detected as usual.
local function manual_root(bufnr)
  local dir = vim.g.rooter_manual_root
  local path = rooter().bufpath(bufnr)
  if not dir or not path then return {} end
  return vim.startswith(path, dir .. "/") and { dir } or {}
end

--- Root at the individual app directory for anything under ~/.config,
--- e.g. ~/.config/kitty/kitty.conf -> ~/.config/kitty
local function xdg_config_app(bufnr)
  local path = rooter().bufpath(bufnr)
  if not path then return {} end
  local base = rooter().normpath(vim.env.XDG_CONFIG_HOME or (vim.env.HOME .. "/.config"))
  local app = path:match("^" .. vim.pesc(base) .. "/([^/]+)")
  if not app then return {} end
  local dir = base .. "/" .. app
  return vim.fn.isdirectory(dir) == 1 and { dir } or {}
end

--- Version control detection that refuses to root at $HOME
local function vcs_not_home(bufnr)
  local path = rooter().bufpath(bufnr)
  if not path then return {} end
  local home = rooter().normpath(vim.env.HOME)
  local found = vim.fs.find({ ".git", "_darcs", ".hg", ".bzr", ".svn" }, { path = path, upward = true })[1]
  if not found then return {} end
  local dir = rooter().normpath(vim.fs.dirname(found))
  return dir ~= home and { dir } or {}
end

--- Drop $HOME from a list of candidate roots
local function without_home(dirs)
  local home = rooter().normpath(vim.env.HOME)
  return vim.tbl_filter(function(dir) return rooter().normpath(dir) ~= home end, dirs)
end

--- Language server workspace roots, excluding $HOME. Servers such as lemminx and
--- jdtls walk up to `~/.git` and report $HOME as the workspace when a project
--- has no git repo of its own.
local function lsp_not_home(bufnr) return without_home(rooter().detectors.lsp()(bufnr)) end

--- Repos that hold several sub-projects but should open as one tree. Files
--- anywhere below these roots use them as root, so ntex/frontend/package.json
--- does not narrow the tree to frontend/.
local pinned_roots = {
  "~/devsrc/rust/ntex",
}

local function pinned_root(bufnr)
  local path = rooter().bufpath(bufnr)
  if not path then return {} end
  for _, root in ipairs(pinned_roots) do
    local dir = rooter().normpath(root)
    if path == dir or vim.startswith(path, dir .. "/") then return { dir } end
  end
  return {}
end

local project_markers = {
  "pom.xml",
  "build.gradle",
  "build.gradle.kts",
  "mvnw",
  "gradlew",
  "Makefile",
  "makefile",
  "CMakeLists.txt",
  "compile_commands.json",
  "meson.build",
  "package.json",
  "Cargo.toml",
  "go.mod",
  "pyproject.toml",
}

--- Nearest known project root marker, excluding $HOME: a stray ~/mvnw would
--- otherwise root every file outside a project at $HOME.
local function markers_not_home(bufnr)
  return without_home(rooter().detectors.pattern()(bufnr, project_markers))
end

--- Last resort: the directory the file itself lives in, never the whole home tree
local function buffer_dir(bufnr)
  local path = rooter().bufpath(bufnr)
  if not path then return {} end
  return { vim.fs.dirname(path) }
end

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    rooter = {
      enabled = true,
      autochdir = true, -- this is the part that's off by default
      scope = "global", -- "global" | "tab" | "win"
      notify = false, -- set true if you want a message on every cwd change
      detector = {
        manual_root, -- a root picked by hand in neo-tree beats every detector
        xdg_config_app, -- ~/.config/<app> wins over the $HOME dotfiles repo
        pinned_root, -- whole-repo roots listed in pinned_roots
        -- Known project root markers come before git: repos such as
        -- ~/devsrc/java hold many Maven projects, and the tree should show the
        -- one project containing the file, not the whole repo.
        markers_not_home,
        vcs_not_home, -- version controlled parent, excluding $HOME itself
        lsp_not_home, -- the workspace root a language server reports, excluding $HOME
        buffer_dir, -- fall back to the file's own directory
      },
      ignore = {
        servers = {}, -- language servers to ignore, e.g. { "efm" }
        dirs = {}, -- directory patterns to never root into, e.g. { "~/.cargo/*" }
      },
    },
  },
}
