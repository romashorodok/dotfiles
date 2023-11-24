return function(use)
    -- :InspectTree
    use({
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require 'modules.tree-sitter.tree_sitter'.setup()
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',

        },
        build = ':TSUpdate',
        lazy = false,
    })

    use {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        lazy  = false,
    }

    use {
        'dasupradyumna/midnight.nvim',
        lazy = false,
        priority = 1000,
        config = function()
            require('midnight')
            vim.cmd.colorscheme 'midnight'
        end
    }
end
