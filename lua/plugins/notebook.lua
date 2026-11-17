-- Pick a cell formatter for notebook.nvim: ruff first, then black.
-- Mason keeps its binaries in stdpath("data")/mason/bin and only puts that
-- directory on PATH once mason.nvim loads, so check it by absolute path too.
-- Returns nil when neither is found, which keeps the plugin default.
local function format_command()
  local mason_bin = vim.fn.stdpath "data" .. "/mason/bin/"
  local function find(name)
    local path = vim.fn.exepath(name)
    if path ~= "" then return path end
    if vim.fn.executable(mason_bin .. name) == 1 then return mason_bin .. name end
  end
  local ruff = find "ruff"
  -- `ruff format` leaves imports alone, so a `--select I` fix pass sorts them first
  if ruff then
    return ruff
      .. " check --select I --fix-only --exit-zero --quiet --stdin-filename cell.py - | "
      .. ruff
      .. " format --stdin-filename cell.py -"
  end
  local black = find "black"
  if black then return black .. " --quiet -" end
end

---@type LazySpec
return {
  {
    "twhlynch/notebook.nvim",
    -- Opens *.ipynb through a BufReadCmd autocmd, so it has to be loaded
    -- before the first notebook is read.
    lazy = false,
    opts = {
      -- the default <Leader>c collides with AstroNvim's close-buffer mapping
      keybind_prefix = "<Leader>j",
      format_command = format_command(),
      -- the plugin's plot theme has a transparent figure that blends into the
      -- transparent terminal; the plot style lives in
      -- ~/.ipython/profile_default/startup/00-plot.py instead
      custom_plot_theme = false,
      hl = {
        -- the default NonText is comment-dim and washes out over the
        -- transparent background; output text should read like code
        output = "Normal",
      },
    },
  },
  -- notebook.nvim sets filetype=python while reading the notebook, but
  -- AstroNvim's file_user_events autocmd later re-fires filetypedetect for the
  -- first file of each buffer, and Neovim's default `ipynb = "json"` then wins.
  -- Report python for notebook.nvim buffers and keep json for everything else.
  {
    "AstroNvim/astrocore",
    ---@type AstroCoreOpts
    opts = {
      filetypes = {
        extension = {
          ipynb = function(_, bufnr)
            local ok, sessions = pcall(require, "notebook.sessions")
            if ok and sessions.is_session(bufnr) then return "python" end
            return "json"
          end,
        },
      },
    },
  },
}
