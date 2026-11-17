-- Show the completion menu as you type a `:` command, so forgotten commands
-- turn up without pressing <Tab>. AstroNvim hides it in the cmdline by default.
-- `/` and `?` searches are left alone, where a popup would only get in the way.

---@type LazySpec
return {
  "saghen/blink.cmp",
  opts = {
    cmdline = {
      completion = {
        menu = { auto_show = function() return vim.fn.getcmdtype() == ":" end },
      },
    },
  },
}
