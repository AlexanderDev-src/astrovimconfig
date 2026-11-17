-- AstroNvim v6 maps <Leader>ff to the snacks picker, not telescope.
-- Add <C-n> inside the files picker to create whatever is typed in the prompt:
-- a trailing "/" makes a directory, anything else makes a file and opens it.
return {
  "folke/snacks.nvim",
  opts = {
    picker = {
      actions = {
        create_file = function(picker)
          local name = vim.trim(picker.input:get())
          if name == "" then
            vim.notify("Picker: empty prompt, nothing to create", vim.log.levels.WARN)
            return
          end

          local is_dir = name:sub(-1) == "/"
          if is_dir then name = name:sub(1, -2) end

          -- A bare name lands next to the file being edited; anything with a
          -- separator is relative to the picker root.
          local base = picker:cwd()
          if not name:find "/" then
            local win = picker.main
            if win and vim.api.nvim_win_is_valid(win) then
              local current = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(win))
              if current ~= "" then base = vim.fn.fnamemodify(current, ":h") end
            end
          end

          local path = vim.fs.normalize(base .. "/" .. name)
          picker:close()

          if is_dir then
            vim.fn.mkdir(path, "p")
            vim.notify("Created directory " .. vim.fn.fnamemodify(path, ":~:."))
            return
          end

          vim.fn.mkdir(vim.fn.fnamemodify(path, ":h"), "p")
          if vim.fn.filereadable(path) == 0 then vim.fn.writefile({}, path) end
          vim.cmd.edit(vim.fn.fnameescape(path))
        end,
      },
      sources = {
        files = {
          win = {
            input = {
              keys = {
                ["<c-n>"] = { "create_file", mode = { "i", "n" } },
              },
            },
          },
        },
      },
    },
  },
}
