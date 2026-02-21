# codecompanion-anthropic-vertex.nvim

![Neovim](https://img.shields.io/badge/Neovim-0.9+-green.svg)
![License](https://img.shields.io/badge/License-Apache_2.0-blue.svg)

A dedicated Google Cloud Vertex AI adapter extension for Anthropic models in [codecompanion.nvim](https://github.com/olimorris/codecompanion.nvim). 

This adapter safely bridges CodeCompanion's native Anthropic capabilities (such as Prompt Caching and Extended Thinking) to Vertex AI's strict API requirements.

## ✨ Features
* **Native Vertex Routing:** Dynamically routes requests based on your `CLOUD_ML_REGION`.
* **Prompt Caching Support:** Supports Anthropic prompt caching mechanisms perfectly on Google Cloud to save tokens on large contexts.
* **Extended Thinking Safety:** Properly handles Anthropic's strict `temperature = 1` requirement when reasoning mode is enabled.
* **Cost Protection:** Defaults `extended_thinking` to `false` globally to prevent runaway API costs, allowing you to explicitly opt-in per interaction.

## ⚡ Requirements
* Neovim >= 0.9.0
* `olimorris/codecompanion.nvim`
* `gcloud` CLI installed and authenticated via `gcloud auth application-default login`

You must export these variables in your shell profile (e.g., `~/.bashrc` or `~/.zshrc`):
```bash
export ANTHROPIC_VERTEX_PROJECT_ID="your-project-id"
export CLOUD_ML_REGION="us-east5"

```

## 📦 Installation

Install the plugin using your preferred package manager and pass the adapter into your CodeCompanion setup.

**Using [lazy.nvim](https://github.com/folke/lazy.nvim):**

```lua
{
  "olimorris/codecompanion.nvim",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-treesitter/nvim-treesitter",
    {
      "YourUsername/codecompanion-anthropic-vertex.nvim",
    }
  },
  opts = {
    extensions = {
      anthropic_vertex = {
        enabled = true,
      }
    },
    adapters = {
      anthropic_vertex = function()
        return require("codecompanion._extensions.anthropic_vertex").adapter()
      end,
    },
    interactions = {
      chat = {
        adapter = "anthropic_vertex",
      },
      inline = {
        adapter = "anthropic_vertex",
      },
      cmd = {
        adapter = "anthropic_vertex",
      },
    },
  },
}

```

## 🧠 Extended Thinking (Reasoning Mode)

Models like Claude 3.7 Sonnet support "Extended Thinking" (reasoning tokens). Because reasoning tokens can quickly become expensive (up to 16,000 hidden tokens per request), **this adapter disables Extended Thinking by default.**

If you want to enable it, the safest approach is to turn it on specifically for the `chat` interaction, while leaving it off for quick `inline` or `cmd` generations.

You can do this by converting the adapter string into a table and overriding the `schema` in your `interactions` block:

```lua
    interactions = {
      chat = {
        adapter = {
          name = "anthropic_vertex",
          schema = {
            extended_thinking = {
              default = true, -- Enable reasoning tokens for chat sessions
            },
          },
        },
      },
      inline = {
        adapter = "anthropic_vertex", -- Remains false (default) to save money
      },
    },

```

## 🤖 Acknowledgements & Credits

* **Built with AI:** The entire logic, debugging, and structure of this plugin was designed and generated entirely by an AI assistant.
* **CodeCompanion:** A massive thank you to [olimorris](https://codecompanion.olimorris.dev/) for creating `codecompanion.nvim`. This adapter relies entirely on his brilliant foundational architecture.

## 📜 License

Apache License 2.0. See [LICENSE](https://www.google.com/search?q=LICENSE) for details.

