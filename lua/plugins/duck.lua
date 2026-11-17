-- A small pet that wanders around the buffer while you code. It draws plain
-- emoji, so unlike pets.nvim it works inside herdr and any other terminal.
-- The second argument to `hatch` is the speed, in steps per second.

---@type LazySpec
return {
  "tamton-aquib/duck.nvim",
  keys = {
    { "<Leader>kc", function() require("duck").hatch("🐈", 0.75) end, desc = "Hatch a cat" },
    { "<Leader>kd", function() require("duck").hatch("🐕", 2) end, desc = "Hatch a dog" },
    { "<Leader>kk", function() require("duck").cook() end, desc = "Send pet home" },
  },
}
