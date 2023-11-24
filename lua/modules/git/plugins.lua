return function(use)
    use {
        "kdheepak/lazygit.nvim",
        config = function()
            local lzgit = require("lazygit")

            vim.keymap.set("n", "<leader>g", lzgit.lazygit)
        end,
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    }
end
