-- ใช้ clipboard ร่วมกับระบบ
vim.opt.clipboard:append "unnamedplus"

-- ออกจาก terminal mode ด้วยปุ่ม Esc
vim.api.nvim_set_keymap("t", "<Esc>", [[<C-\><C-n>]], { noremap = true, silent = true })

vim.api.nvim_set_keymap("t", "jk", [[<C-\><C-n>]], { noremap = true, silent = true })
-- This will run last in the setup process.
-- This is just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- ใช้ zsh เป็น shell ของ :terminal (ไม่ต้องพึ่ง $SHELL ที่อาจค้างเป็น fish)
vim.opt.shell = "/usr/bin/zsh"

-- notebook.nvim reads *.ipynb in BufReadCmd, where an existing swap file throws
-- E325 instead of prompting; open that notebook read-only without a swap file
local function guard_notebook_swap(buf)
  local path = vim.api.nvim_buf_get_name(buf)
  if not path:match "%.ipynb$" then return end
  local swap = vim.fn.stdpath "state" .. "/swap/" .. (path:gsub("/", "%%")) .. ".swp"
  if vim.uv.fs_stat(swap) then
    vim.bo[buf].swapfile = false
    vim.bo[buf].readonly = true
    vim.schedule(function() vim.notify("Notebook has a swap file (open elsewhere?), opened read-only", vim.log.levels.WARN) end)
  end
end
vim.api.nvim_create_autocmd("BufNew", { callback = function(args) guard_notebook_swap(args.buf) end })
-- files given on the command line already have a buffer before this file runs
for _, buf in ipairs(vim.api.nvim_list_bufs()) do
  guard_notebook_swap(buf)
end
