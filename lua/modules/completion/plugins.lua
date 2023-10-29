return function(use)
    use({
        'neovim/nvim-lspconfig',
        lazy = true,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
        },
    })

    use({
        'hrsh7th/nvim-cmp',
        module = false,
        event = { 'InsertEnter', 'CmdlineEnter' }, 
        config = function() 
            require'modules.completion.cmp'.setup()
        end,
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp',
            'rafamadriz/friendly-snippets',
        },
    })
end
