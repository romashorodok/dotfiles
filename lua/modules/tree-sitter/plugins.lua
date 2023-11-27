return function(use)
    -- :InspectTree
    use {
        'nvim-treesitter/nvim-treesitter',
        config = function()
            require 'modules.tree-sitter.tree_sitter'.setup()
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter-textobjects',

        },
        build = ':TSUpdate',
        lazy = false,
    }

    use {
        'nvim-treesitter/nvim-treesitter-context',
        dependencies = {
            'nvim-treesitter/nvim-treesitter',
        },
        lazy = false,
    }

    use {
        "folke/noice.nvim",
        event = "VeryLazy",
        config = function()
            require("noice").setup {
                lsp = {
                    -- override = {
                    --     ["vim.lsp.util.convert_input_to_markdown_lines"] = true,
                    --     ["vim.lsp.util.stylize_markdown"] = true,
                    --     ["cmp.entry.get_documentation"] = true,
                    -- },
                },
                presets = {
                    -- bottom_search = true,         -- use a classic bottom cmdline for search
                    -- command_palette = true,       -- position the cmdline and popupmenu together
                    -- long_message_to_split = true, -- long messages will be sent to a split
                    -- inc_rename = false,           -- enables an input dialog for inc-rename.nvim
                    -- lsp_doc_border = false,       -- add a border to hover docs and signature help
                },
            }
        end,
        opts = {
            -- add any options here
        },
        dependencies = {
            "MunifTanjim/nui.nvim",
        }
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
