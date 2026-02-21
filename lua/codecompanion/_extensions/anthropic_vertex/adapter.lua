return function()
  local log = require("codecompanion.utils.log")
  log:info("Initializing Anthropic Vertex AI adapter")

  return require("codecompanion.adapters").extend("anthropic", {
    name = "anthropic_vertex",
    formatted_name = "Anthropic (Vertex AI)",

    env = {
      project_id = function()
        local id = vim.env.ANTHROPIC_VERTEX_PROJECT_ID
        if not id or id == "" then
          log:error("Vertex AI Adapter: Missing ANTHROPIC_VERTEX_PROJECT_ID")
          error("CodeCompanion: Missing required environment variable 'ANTHROPIC_VERTEX_PROJECT_ID'")
        end
        return id
      end,

      location = function()
        local loc = vim.env.CLOUD_ML_REGION
        if not loc or loc == "" then
          log:error("Vertex AI Adapter: Missing CLOUD_ML_REGION")
          error("CodeCompanion: Missing required environment variable 'CLOUD_ML_REGION'")
        end
        return loc
      end,

      url_prefix = function()
        local loc = vim.env.CLOUD_ML_REGION
        return loc == "global" and "" or (loc .. "-")
      end,

      model = function(self)
        return self.schema.model.default
      end,

      action = function(self)
        return self.opts and self.opts.stream and "streamRawPredict" or "rawPredict"
      end,

      bearer_token = "cmd:gcloud auth application-default print-access-token 2>/dev/null | tr -d '\n'",
    },

    url = "https://${url_prefix}aiplatform.googleapis.com/v1/projects/${project_id}/locations/${location}/publishers/anthropic/models/${model}:${action}",

    headers = {
      ["Content-Type"] = "application/json",
      ["Authorization"] = "Bearer ${bearer_token}",
    },

    schema = {
      extended_thinking = {
        default = false, -- Safety switch: OFF by default to save tokens
      },
    },

    handlers = {
      setup = function(self)
        log:debug("Running Vertex AI setup")

        self.headers["x-api-key"] = nil
        self.headers["anthropic-version"] = nil
        self.headers["anthropic-beta"] = nil

        if self.opts and self.opts.stream then
          self.parameters.stream = true
        end

        local model = self.schema.model.default
        local model_opts = self.schema.model.choices[model]
        if model_opts and model_opts.opts then
          self.opts = vim.tbl_deep_extend("force", self.opts, model_opts.opts)
          if not model_opts.opts.has_vision then
            self.opts.vision = false
          end
        end

        if self.temp.extended_output then
          self.headers["anthropic-beta"] = (
            self.headers["anthropic-beta"] and self.headers["anthropic-beta"] .. "," or ""
          ) .. "output-128k-2025-02-19"
        end

        if self.opts.has_token_efficient_tools then
          self.headers["anthropic-beta"] = (
            self.headers["anthropic-beta"] and self.headers["anthropic-beta"] .. "," or ""
          ) .. "token-efficient-tools-2025-02-19"
        end

        return true
      end,

      form_parameters = function(self, params, messages)
        log:debug("Running Vertex AI form_parameters")

        params.anthropic_version = "vertex-2023-10-16"
        params.model = nil

        if self.temp.extended_thinking and self.temp.thinking_budget then
          params.thinking = {
            type = "enabled",
            budget_tokens = self.temp.thinking_budget,
          }
          params.temperature = 1
        end

        return params
      end,
    },
  })
end
