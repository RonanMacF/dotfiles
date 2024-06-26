vim.api.nvim_set_keymap('n', '<Leader>ff', ':Telescope find_files<CR>', {noremap = true, silent = true})

-- vista
vim.api.nvim_set_keymap('n', '<Leader>vf', ':Vista finder nvim_lsp<CR>', {noremap = true, silent = true}) -- vista finder
vim.api.nvim_set_keymap('n', '<Leader>vv', ':Vista!!', {noremap = true, silent = true}) -- vista vista

-- nvim-dap
vim.api.nvim_set_keymap('n', 'bb', ":lua require'dap'.toggle_breakpoint()<CR>", {noremap = false, silent = false})

