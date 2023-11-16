local filetypes = {
    'html',
    'css',
    'javascript',
    'java',
    'javascriptreact',
    'vue',
    'typescript',
    'typescriptreact',
    'go',
    'lua',
    'cpp',
    'c',
    'markdown',
    'makefile',
    'python',
    'bash',
    'sh',
    'php',
    'yaml',
    'json',
    'sql',
    'vim',
    'sh',
    'svelte',
    'dockerfile',
    'graphgql',
}

return function(use)
    use({
        'neovim/nvim-lspconfig',
        lazy = false,
        module = false,
        config = function()
            require('modules.completion.lsp').setup()
        end,
        ft = filetypes,
        dependencies = {
            'williamboman/mason.nvim',
            'williamboman/mason-lspconfig.nvim',
            { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
        },
    })

    use({
        'hrsh7th/nvim-cmp',
        module = false,
        lazy = true,
        event = { 'InsertEnter', 'CmdlineEnter' },
        config = function()
            require 'modules.completion.cmp'.setup()
        end,
        dependencies = {
            'L3MON4D3/LuaSnip',
            'saadparwaiz1/cmp_luasnip',
            'hrsh7th/cmp-nvim-lsp',
            'rafamadriz/friendly-snippets',
        },
    })

    use {
        'numtostr/comment.nvim',
        lazy = false,
        module = false,
        opts = {},
    }

    use {
        'mbbill/undotree',
        lazy = false,
        module = false,
        config = function()
            vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
        end
    }

    use {
        "windwp/nvim-autopairs",
        lazy = false,
        wants = "nvim-treesitter",
        module = { "nvim-autopairs.completion.cmp", "nvim-autopairs" },
        config = function()
            local npairs = require "nvim-autopairs"
            npairs.setup {
                check_ts = true,
            }
            npairs.add_rules(require "nvim-autopairs.rules.endwise-lua")
        end
    }
end
