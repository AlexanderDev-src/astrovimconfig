-- RustOwl: rest the cursor on a variable to underline where it lives, is
-- borrowed and is moved. Off by default upstream (`:Rustowl toggle`); on here.
-- Each underline also gets its meaning written at the end of the line, in the
-- same color, so the colors don't have to be remembered.

-- lifetime kinds underline every line the variable lives on; label only the first
local lifetime = { definitely_live = true, maybe_initialized = true }

-- Same request and underlines as rustowl.highlight.enable, plus the labels.
-- Its namespace is shared, so the plugin's own disable clears both.
local function enable(line, col, bufnr)
  bufnr = bufnr or vim.api.nvim_get_current_buf()
  local ns = vim.api.nvim_create_namespace "rustowl"
  local colors = require("rustowl.config").colors
  local params = {
    position = { line = line - 1, character = col },
    document = vim.lsp.util.make_text_document_params(bufnr),
  }
  for _, client in ipairs(require("rustowl.lsp").get_rustowl_clients { bufnr = bufnr }) do
    client:request("rustowl/cursor", params, function(_, result)
      if not result or not vim.api.nvim_buf_is_valid(bufnr) then return end
      local labels, seen, first = {}, {}, {}
      local function label(deco)
        local row, text = deco.range.start.line, deco.hover_text or deco.type
        -- kinds without a color (e.g. "lifetime") have no visible underline to explain
        if seen[row .. text] or not colors[deco.type] then return end
        seen[row .. text] = true
        local group = "RustowlLabel_" .. deco.type
        vim.api.nvim_set_hl(0, group, { fg = colors[deco.type], italic = true, default = true })
        labels[row] = labels[row] or {}
        table.insert(labels[row], { "  " .. text, group })
      end
      for _, deco in ipairs(result.decorations) do
        if not deco.overlapped then
          local s, e = deco.range.start, deco.range["end"]
          vim.hl.range(bufnr, ns, deco.type, { s.line, s.character }, { e.line, e.character }, { inclusive = false })
          if not lifetime[deco.type] then
            label(deco)
          elseif not first[deco.type] or s.line < first[deco.type].range.start.line then
            first[deco.type] = deco
          end
        end
      end
      for _, deco in pairs(first) do
        label(deco)
      end
      for row, chunks in pairs(labels) do
        vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, { virt_text = chunks })
      end
    end, bufnr)
  end
end

---@type LazySpec
return {
  "cordx56/rustowl",
  optional = true,
  opts = {
    auto_enable = true,
    -- catppuccin macchiato; the default #0000cc borrow blue is unreadable on a dark background
    colors = {
      definitely_live = "#a6da95", -- green: the variable is alive here
      maybe_initialized = "#a6da95",
      imm_borrow = "#8aadf4", -- blue: &
      mut_borrow = "#c6a0f6", -- mauve: &mut
      move = "#eed49f", -- yellow: moved away
      call = "#f5a97f", -- peach: passed to a function
      shared_mut = "#ed8796", -- red: & and &mut at once
      outlive = "#ed8796", -- red: borrowed longer than it lives
    },
  },
  config = function(_, opts)
    require("rustowl").setup(opts)
    require("rustowl.highlight").enable = enable
  end,
}
