
return function(use)
    use({
      'folke/neodev.nvim',
      dependencies = {
          'neovim/nvim-lspconfig',
      },
      ft = { "lua" },
      config = function()
          require'modules.lua.config'.setup()
      end
    })
end
