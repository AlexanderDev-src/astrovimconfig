-- Oracle-only sqlplus runner, schema drawer and completion.
-- Connect with :OraGo (picks an ORA_URL_<NAME> env var) ; run with <F8>.
---@type LazySpec

-- Names of ORA_URL_<NAME> env vars, e.g. ORA_URL_PERSONAL -> "personal".
local function ora_names()
  local names = {}
  for key in pairs(vim.fn.environ()) do
    local name = key:match "^ORA_URL_(.+)$"
    if name then names[#names + 1] = name:lower() end
  end
  table.sort(names)
  return names
end

local function ora_go(name)
  local url = vim.env["ORA_URL_" .. name:upper()]
  if not url or url == "" then
    return vim.notify("ORA_URL_" .. name:upper() .. " is not set", vim.log.levels.ERROR)
  end
  require("oravim").connect(url)
end

return {
  {
    "KaravellasYiannis/oravim.nvim",
    ft = { "sql", "plsql" },
    cmd = { "OraConnect", "OraToggle", "OraSave", "OraGo" },
    config = function()
      require("oravim").setup {
        drawer = { position = "right" },
        -- SQLcl for <space>pp; SQL Developer ships it.
        sqlcl = vim.fn.expand "~/.local/bin/sqlcl",
      }
      vim.api.nvim_create_user_command("OraGo", function(opts)
        if opts.args ~= "" then return ora_go(opts.args) end
        local names = ora_names()
        if #names == 0 then
          return vim.notify("No ORA_URL_<NAME> env vars found", vim.log.levels.ERROR)
        end
        if #names == 1 then return ora_go(names[1]) end
        vim.ui.select(names, { prompt = "Oracle connection" }, function(choice)
          if choice then ora_go(choice) end
        end)
      end, { nargs = "?", complete = ora_names, desc = "Connect to Oracle from ORA_URL_<NAME>" })
    end,
  },
  {
    "saghen/blink.cmp",
    optional = true,
    opts = function(_, opts)
      opts.sources = opts.sources or {}
      opts.sources.providers = opts.sources.providers or {}
      opts.sources.providers.oravim = { name = "oravim", module = "oravim.blink" }
    end,
  },
}
