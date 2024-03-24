return function(use)
    use {
        "kdheepak/lazygit.nvim",
        config = function()
            local lzgit = require("lazygit")

            vim.keymap.set("n", "<leader>gg", lzgit.lazygit)
        end,
        lazy = false,
        dependencies = {
            "nvim-lua/plenary.nvim",
        },
    }
    use
    {
        'akinsho/git-conflict.nvim',
        event = 'VeryLazy',
        opts = {
            default_mappings = {
                ours = '<leader>g1',
                theirs = '<leader>g2',
                none = '<leader>g0',
                both = '<leader>g3',
                prev = '[g',
                next = ']g',
            },
            disable_diagnostics = true,
        },
    }
end
