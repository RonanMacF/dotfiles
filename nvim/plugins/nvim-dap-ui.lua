require("dapui").setup({
  icons = {
    expanded = "⯆",
    collapsed = "⯈"
  },
  mappings = {
    -- Use a table to apply multiple mappings
    expand = {"<CR>", "<2-LeftMouse>"},
    open = "o",
    remove = "d",
    edit = "e",
  },
  sidebar = {
    elements = {
      -- You can change the order of elements in the sidebar
      "scopes",
      "stacks",
    },
    width = 60,
    position = "left" -- Can be "left" or "right"
  },
  tray = {
    elements = {
      "repl"
    },
    height = 10,
    position = "bottom" -- Can be "bottom" or "top"
  },
  floating = {
    max_height = 0.5, -- These can be integers or a float between 0 and 1.
    max_width = 0.5   -- Floats will be treated as percentage of your scren.
  }
})

vim.g.dap_virtual_text = 'all frames'

local widgets = require('dap.ui.widgets')
local dap = require('dap')
vim.api.nvim_set_keymap('n', 'll', 'widgets.centered_float(widgets.scopes)', {expr = true, noremap = true})

vim.fn.sign_define('DapBreakpoint', {text='🛑', texthl='', linehl='', numhl=''})
  
-- Completion will then trigger automatically on any of the completion trigger
-- characters reported by the debug adapter or if none are reported on `.`.
-- au FileType dap-repl lua require('dap.ext.autocompl').attach()

-- If you want to use the `externalTerminal` you need to setup the terminal which
-- should be launched by nvim-dap:

dap.defaults.fallback.external_terminal = {
  command = '/usr/bin/alacritty'; -- external terminal
  args = {'-e'};
}
dap.defaults.fallback.terminal_win_cmd = '50vsplit new' -- internal terminal

