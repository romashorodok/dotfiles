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
    'nix',
    'pyrex',
    'rust',
}

return function(use)
    vim.cmd("autocmd BufEnter *.js :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.ts :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.jsx :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.tsx :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.svelte :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.proto :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.nix :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.c :setlocal tabstop=2 shiftwidth=2 expandtab")
    vim.cmd("autocmd BufEnter *.cpp :setlocal tabstop=2 shiftwidth=2 expandtab")

    vim.cmd("set listchars=tab:⇤–⇥,space:·,trail:·,precedes:⇠,extends:⇢,nbsp:×")
    vim.cmd("autocmd BufEnter *.sql :set list")

    vim.g.zig_fmt_autosave = 0

    use({
        'neovim/nvim-lspconfig',
        lazy = false,
        module = false,
        config = function()
            require('modules.completion.lsp').setup()
        end,
        ft = filetypes,
        dependencies = {
            -- 'williamboman/mason.nvim',
            -- 'williamboman/mason-lspconfig.nvim',
            -- { 'j-hui/fidget.nvim', tag = 'legacy', opts = {} },
        },
    })

    vim.keymap.set('n', 'U', '<C-r>', { noremap = true, silent = true })

    -- use {
    --     'mbbill/undotree',
    --     lazy = false,
    --     module = false,
    --     config = function()
    --         vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
    --     end
    -- }

    require 'modules.completion.pairs'.setup()
    require 'modules.completion.comments'.setup({
        mappings = {
            comment = '<leader>c',
            comment_line = '<leader>c',
            comment_visual = '<leader>c',
            textobject = '<leader>c',
        },
    })
end
