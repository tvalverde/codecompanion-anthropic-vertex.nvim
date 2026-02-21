local new_set = MiniTest.new_set
local expect = MiniTest.expect

local T = new_set()

-- Load our adapter function
local get_adapter = require("codecompanion._extensions.anthropic_vertex.adapter")

T["Adapter Initialization"] = new_set()

T["Adapter Initialization"]["should return a valid adapter table"] = function()
  local adapter = get_adapter()
  expect.equality(type(adapter), "table")
  expect.equality(adapter.name, "anthropic_vertex")
end

T["Handlers: setup()"] = new_set()

T["Handlers: setup()"]["should strip legacy Anthropic headers"] = function()
  local adapter = get_adapter()
  
  -- Run the setup handler
  adapter.handlers.setup(adapter)

  -- Verify Google-incompatible headers are removed
  expect.equality(adapter.headers["x-api-key"], nil)
  expect.equality(adapter.headers["anthropic-version"], nil)
  expect.equality(adapter.headers["anthropic-beta"], nil)
end

T["Handlers: form_parameters()"] = new_set()

T["Handlers: form_parameters()"]["should remove model from body and set vertex version"] = function()
  local adapter = get_adapter()
  local params = { model = "claude-haiku-4-5", temperature = 0.5 }
  
  -- Run the form_parameters handler
  local new_params = adapter.handlers.form_parameters(adapter, params, {})

  -- Verify model is removed (Vertex expects it in URL)
  expect.equality(new_params.model, nil)
  
  -- Verify vertex version is injected into the body
  expect.equality(new_params.anthropic_version, "vertex-2023-10-16")
end

T["Handlers: form_parameters()"]["should force temperature to 1 when thinking is enabled"] = function()
  local adapter = get_adapter()
  local params = { temperature = 0 }
  
  -- Simulate a user turning on extended thinking
  adapter.temp = {
    extended_thinking = true,
    thinking_budget = 4000
  }
  
  local new_params = adapter.handlers.form_parameters(adapter, params, {})

  -- Verify Anthropic's strict reasoning requirements are enforced
  expect.equality(new_params.temperature, 1)
  expect.equality(type(new_params.thinking), "table")
  expect.equality(new_params.thinking.budget_tokens, 4000)
end

return T
