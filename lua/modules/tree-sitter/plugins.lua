return function(use)
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
end
