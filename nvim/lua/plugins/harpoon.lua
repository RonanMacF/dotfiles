return {
  "ThePrimeagen/harpoon",
  branch = "harpoon2",
  keys = function()
    local harpoon = require("harpoon")
    local keys = {
      { "<leader>H", function() harpoon:list():add() end, desc = "Harpoon Add File" },
      { "<leader>h", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end, desc = "Harpoon Menu" },
    }
    for i = 1, 5 do
      table.insert(keys, {
        "<M-" .. i .. ">",
        function() harpoon:list():select(i) end,
        desc = "Harpoon File " .. i,
      })
    end
    return keys
  end,
}
