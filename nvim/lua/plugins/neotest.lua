return {
  {
    "nvim-neotest/neotest",
    dependencies = { "fredrikaverpil/neotest-golang" },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-golang"] = {}
    end,
  },
  {
    "mfussenegger/nvim-dap-python",
    config = function()
      -- Set up with python3 as base, then override the adapter to resolve
      -- $VIRTUAL_ENV dynamically at session start rather than at plugin load.
      require("dap-python").setup("python3")
      local dap = require("dap")
      dap.adapters.python = function(cb, config)
        local venv = vim.env.VIRTUAL_ENV
        local py = (venv and vim.fn.executable(venv .. "/bin/python") == 1)
          and venv .. "/bin/python"
          or config.pythonPath or "python3"
        cb({
          type = "executable",
          command = py,
          args = { "-m", "debugpy.adapter" },
        })
      end
    end,
  },
  {
    "nvim-neotest/neotest",
    dependencies = { "nvim-neotest/neotest-python" },
    opts = function(_, opts)
      opts.adapters = opts.adapters or {}
      opts.adapters["neotest-python"] = {
        runner = "pytest",
        -- Prefer direnv-activated venv, skip broken project-local .venv discovery
        python = function()
          local venv = vim.env.VIRTUAL_ENV
          if venv then
            local py = venv .. "/bin/python"
            if vim.fn.executable(py) == 1 then
              return py
            end
          end
          return "python3"
        end,
      }
      -- Fix: subprocess nvim can't find treesitter via lazy — disable subprocess discovery
      -- and run synchronously in the main process instead.
      opts.discovery = { enabled = false }
      return opts
    end,
  },
}
