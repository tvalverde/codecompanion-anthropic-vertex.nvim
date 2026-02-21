-- 1. Set up the Neovim runtime path to include the current plugin directory
local current_dir = vim.fn.getcwd()
vim.opt.rtp:prepend(current_dir)

-- 2. Add the downloaded mini.nvim to the runtime path
local deps_dir = current_dir .. "/.tests/deps"
vim.opt.rtp:prepend(deps_dir .. "/mini.nvim")

-- 3. Mock codecompanion so our adapter doesn't crash when it tries to extend it
package.loaded["codecompanion.adapters"] = {
  extend = function(base, custom)
    -- Simply merge the custom adapter over a mock base to test the logic
    local mock_base = {
      opts = {},
      headers = {
        ["x-api-key"] = "mock_key",
        ["anthropic-version"] = "2023-06-01",
        ["anthropic-beta"] = "prompt-caching-2024-07-31",
      },
      parameters = {},
      schema = {
        model = {
          default = "claude-haiku-4-5",
          choices = {
            ["claude-haiku-4-5"] = { opts = { can_reason = false } }
          }
        }
      },
      temp = {}
    }
    return vim.tbl_deep_extend("force", mock_base, custom)
  end,
}
package.loaded["codecompanion.utils.log"] = {
  info = function() end,
  debug = function() end,
  error = function() end,
}

-- 4. Setup and start mini.test
require("mini.test").setup()
