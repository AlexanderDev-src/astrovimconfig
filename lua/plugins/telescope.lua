return {
  "nvim-telescope/telescope.nvim",
  opts = function(_, opts)
    if not opts.pickers then
      opts.pickers = {}
    end
    if not opts.pickers.find_files then
      opts.pickers.find_files = {}
    end

    -- Include hidden files (dotfiles like .gitignore, .env) in search
    opts.pickers.find_files.hidden = true

    -- Do not search inside .git folder
    opts.pickers.find_files.file_ignore_patterns = opts.pickers.find_files.file_ignore_patterns or {}
    table.insert(opts.pickers.find_files.file_ignore_patterns, "^%.git/")

    return opts
  end,
}
