-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set({ "i", "n" }, "<C-s>", "<cmd>w<cr>", { desc = "Save" })

vim.keymap.set("n", "<leader>gP", function()
  require("gitsigns").blame_line({ full = false, ignore_whitespace = true }, function(blame)
    if not blame or blame.author == "Not Committed Yet" then
      vim.notify("Line not committed", vim.log.levels.WARN)
      return
    end
    local hash = blame.sha
    local result = vim.fn.system("gh pr list --search " .. hash .. " --state merged --json number,title --limit 1")
    local ok, prs = pcall(vim.json.decode, result)
    if not ok or not prs or #prs == 0 then
      vim.notify("No merged PR found for commit " .. hash:sub(1, 8), vim.log.levels.WARN)
      return
    end
    vim.cmd("Octo pr edit " .. prs[1].number)
  end)
end, { desc = "Open PR for current line" })
