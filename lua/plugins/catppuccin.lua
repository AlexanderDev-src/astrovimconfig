return {
  "catppuccin/nvim",
  name = "catppuccin",
  lazy = false,
  priority = 1000,
  ---@type CatppuccinOptions
  ---@diagnostic disable: missing-fields
  opts = {
    flavour = "macchiato",
    auto_integrations = true,
    -- สีบอกว่าเป็นอะไร (ตาม style guide ของ catppuccin), หนา = ที่ประกาศ,
    -- เอียง (Maple Mono วาดเป็นตัวเขียน) = comment, keyword, parameter, self/this
    -- ตัวแปร, การเรียก function, property ที่มีเต็มไฟล์ยังเป็นตัวธรรมดา จะได้ไม่รกตา
    styles = {
      comments = { "italic" },
      conditionals = { "italic" },
      loops = { "italic" },
      keywords = { "italic" },
      miscs = {}, -- ปิดตัวเอียงที่ catppuccin ใส่ไว้เอง เช่นชื่อ module
    },
    custom_highlights = function(colors)
      return {
        -- function/method: ฟ้าเหมือนกัน, ที่ประกาศหนา, ที่เรียกใช้ตัวธรรมดา
        ["@function"] = { fg = colors.blue, style = { "bold" } },
        ["@function.method"] = { fg = colors.blue, style = { "bold" } },
        ["@function.call"] = { fg = colors.blue },
        ["@function.method.call"] = { fg = colors.blue },

        -- parameter: maroon เอียง เห็นทันทีว่าค่ามาจากข้างนอก function
        ["@variable.parameter"] = { fg = colors.maroon, style = { "italic" } },
        ["@variable.builtin"] = { fg = colors.red, style = { "italic" } }, -- self, this

        -- type ทุกแบบสีเหลือง รวมถึง int, str, bool
        ["@type.builtin"] = { fg = colors.yellow },

        -- ให้ LSP ใช้หน้าตาเดียวกับข้างบน
        ["@lsp.type.function"] = { link = "@function.call" },
        ["@lsp.type.method"] = { link = "@function.method.call" },
        ["@lsp.type.parameter"] = { link = "@variable.parameter" },
        ["@lsp.type.selfKeyword"] = { link = "@variable.builtin" }, -- rust-analyzer
        ["@lsp.typemod.function.declaration"] = { link = "@function" },
        ["@lsp.typemod.method.declaration"] = { link = "@function.method" },
      }
    end,
    integrations = {
      colorful_winsep = { color = "lavender" },
      snacks = {
        indent_scope_color = "lavender",
      },
      neotree = true,
      notify = false,
      neogit = true,
    },
  },
  specs = {
    {
      "akinsho/bufferline.nvim",
      optional = true,
      opts = function(_, opts)
        return require("astrocore").extend_tbl(opts, {
          highlights = require("catppuccin.special.bufferline").get_theme(),
        })
      end,
    },
  },
}
