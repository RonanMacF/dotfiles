require("ultest").setup({
  builders = {
    ["go#gotest"] = function(cmd)
      local args = {}
      for i = 3, #cmd - 1, 1 do
        local arg = cmd[i]
        if vim.startswith(arg, "-") then
          -- Delve requires test flags be prefix with 'test.'
          arg = "-test." .. string.sub(arg, 2)
        end
        args[#args + 1] = arg
      end
      return {
	dap = {
		type = "go",
		name = "Debug test",
		request = "launch",
		mode = "test", -- Mode is important
                program = "${workspaceFolder}",
                  -- program = "${file}"
                dlvToolPath = vim.fn.exepath("dlv"),
                args = args
	},
        -- parse_result = function(lines)
        --   return lines[#lines] == "FAIL" and 1 or 0
        -- end
      }
    end,
    ['python#pytest'] = function(cmd)
      -- The command can start with python command directly or an env manager
      local non_modules = {'python', 'pipenv', 'poetry'}
      -- Index of the python module to run the test.
      local module
      if vim.tbl_contains(non_modules, cmd[1]) then
        module = cmd[3]
      else
        module = cmd[1]
      end
      -- Remaining elements are arguments to the module
      local args = vim.list_slice(cmd, module_index + 1)
      return {
        dap = {
          type = 'python',
          request = 'launch',
          module = module,
          args = args
        }
      }
    end

  }
})

