-- Disable Mason -- all LSPs, formatters, linters, and DAP adapters are
-- provided by Nix via home-manager's home.packages. Binaries are on $PATH.
return {
  { "mason-org/mason.nvim", enabled = false },
  { "mason-org/mason-lspconfig.nvim", enabled = false },
  { "jay-babu/mason-nvim-dap.nvim", enabled = false },
}
