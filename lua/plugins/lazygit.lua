-- lazygit in a floating window, instead of AstroNvim's default toggleterm split.
-- Requires the `lazygit` binary on PATH (`pacman -S lazygit`).
---@type LazySpec
return {
  {
    "kdheepak/lazygit.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    -- `cmd` lets lazy.nvim stub the commands so they exist before the plugin loads
    cmd = {
      "LazyGit",
      "LazyGitConfig",
      "LazyGitCurrentFile",
      "LazyGitFilter",
      "LazyGitFilterCurrentFile",
    },
    init = function()
      -- let the plugin own the floating window; AstroNvim/snacks handles borders
      vim.g.lazygit_floating_window_scaling_factor = 0.95
      vim.g.lazygit_floating_window_border_chars = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" }
      vim.g.lazygit_use_neovim_remote = 0 -- no neovim-remote installed
    end,
    keys = {
      { "<Leader>gg", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
      { "<Leader>tl", "<Cmd>LazyGit<CR>", desc = "LazyGit" },
      { "<Leader>gF", "<Cmd>LazyGitCurrentFile<CR>", desc = "LazyGit (current file's repo)" },
      { "<Leader>gL", "<Cmd>LazyGitFilterCurrentFile<CR>", desc = "LazyGit commits for current file" },
    },
  },
}
