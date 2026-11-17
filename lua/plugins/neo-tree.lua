return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = function(_, opts)
    if not opts.filesystem then
      opts.filesystem = {}
    end
    if not opts.filesystem.filtered_items then
      opts.filesystem.filtered_items = {}
    end

    -- Show dotfiles (e.g. .gitignore, .neoconf.json)
    opts.filesystem.filtered_items.hide_dotfiles = false
    -- Show git ignored files/folders
    opts.filesystem.filtered_items.hide_gitignored = false
    -- Show hidden files on Windows
    opts.filesystem.filtered_items.hide_hidden = false

    -- Ensure ".git" directory is not hidden under hide_by_name
    if opts.filesystem.filtered_items.hide_by_name then
      for i, name in ipairs(opts.filesystem.filtered_items.hide_by_name) do
        if name == ".git" then
          table.remove(opts.filesystem.filtered_items.hide_by_name, i)
          break
        end
      end
    end

    -- Ensure ".git" directory is not hidden under never_show
    if opts.filesystem.filtered_items.never_show then
      for i, name in ipairs(opts.filesystem.filtered_items.never_show) do
        if name == ".git" then
          table.remove(opts.filesystem.filtered_items.never_show, i)
          break
        end
      end
    end

    -- `.` (set_root) and `<BS>` (navigate_up) change the cwd, and the rooter in
    -- rooter.lua changes it back on the next BufEnter. Record the directory
    -- picked here so its `manual_root` detector keeps it.
    opts.filesystem.commands = opts.filesystem.commands or {}
    for _, name in ipairs { "set_root", "navigate_up" } do
      opts.filesystem.commands[name] = function(state)
        require("neo-tree.sources.filesystem.commands")[name](state)
        vim.g.rooter_manual_root = require("astrocore.rooter").realpath(state.path)
      end
    end

    return opts
  end,
}
