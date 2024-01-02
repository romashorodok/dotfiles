return function(use)
    -- use {
    --     'nvim-telescope/telescope.nvim',
    --     branch       = '0.1.x',
    --     lazy         = false,
    --     config       = function()
    --         require 'modules.telescope.config'.setupTelescope()
    --     end,
    --     dependencies = {
    --         'nvim-lua/plenary.nvim',
    --         {
    --             'nvim-telescope/telescope-fzf-native.nvim',
    --             build = 'make',
    --             cond = function()
    --                 return vim.fn.executable 'make' == 1
    --             end,
    --         },
    --     },
    -- }

    use {
        "ibhagwan/fzf-lua",
        lazy = false,
        -- optional for icon support
        -- dependencies = { "nvim-tree/nvim-web-devicons" },
        config = function()
            require 'fzf-lua'.setup {}
            require 'modules.telescope.config'.setupFzf()
        end
    }
end
