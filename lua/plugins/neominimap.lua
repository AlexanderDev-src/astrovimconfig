-- Start with the minimap hidden. <Leader>um still toggles it on for the session.

---@type LazySpec
return {
  "Isrothy/neominimap.nvim",
  optional = true,
  opts = { auto_enable = false },
}
