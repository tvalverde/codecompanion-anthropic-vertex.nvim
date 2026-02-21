---@class CodeCompanion.Extension
---@field setup fun(opts: table) Function called when extension is loaded
---@field exports? table Functions exposed via codecompanion.extensions.anthropic_vertex
---@field adapter fun(): table The actual Vertex AI adapter
local Extension = {}

Extension.adapter = require("codecompanion._extensions.anthropic_vertex.adapter")

---Setup the extension
---@param opts table Configuration options
function Extension.setup(opts)
  -- Adapter extension entry point
end

Extension.exports = {
  adapter = Extension.adapter,
}

return Extension
