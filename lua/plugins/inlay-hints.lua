-- Grey type hints from the language server, shown at the end of the line.
-- Toggle with <Leader>uH (all buffers) or <Leader>uh (this buffer).

---@type LazySpec
return {
  {
    "AstroNvim/astrolsp",
    ---@type AstroLSPOpts
    opts = {
      features = { inlay_hints = true },
      config = {
        -- Type and chaining hints are on by default; these add the ones about
        -- ownership and closures.
        rust_analyzer = {
          settings = {
            ["rust-analyzer"] = {
              inlayHints = {
                closureReturnTypeHints = { enable = "always" }, -- |c| -> Result<u8, _>
                closureCaptureHints = { enable = true }, -- move(&x)
                bindingModeHints = { enable = true }, -- ref / & in patterns
                lifetimeElisionHints = { enable = "skip_trivial" }, -- 'a on fn signatures
              },
            },
          },
        },
      },
    },
  },
  {
    "chrisgrieser/nvim-lsp-endhints",
    optional = true,
    opts = {
      label = {
        truncateAtChars = false, -- default cuts at 20 chars: "impl Iterator<Item =…"
        marginLeft = 1, -- "inline" text has no gap of its own, unlike "eol"
      },
    },
    -- The plugin hardcodes virt_text_pos = "eol", and Neovim never soft-wraps
    -- eol text: a long hint runs off the window edge. Inline text does wrap,
    -- so redraw the plugin's marks as inline text at the end of the line.
    init = function()
      local ns = vim.api.nvim_create_namespace "lspEndhints"
      local set_extmark = vim.api.nvim_buf_set_extmark
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.api.nvim_buf_set_extmark = function(buf, mark_ns, line, col, opts)
        if mark_ns == ns and opts.virt_text_pos == "eol" then
          opts.virt_text_pos = "inline"
          col = vim.v.maxcol -- strict = false clamps this to the end of the line
        end
        return set_extmark(buf, mark_ns, line, col, opts)
      end
    end,
  },
}
