local config = {}


function config.setup()
    require('telescope').setup {
        defaults = {
            mappings = {
                i = {
                    ['<C-u>'] = false,
                    ['<C-d>'] = false,
                },
            },
        },
    }

    pcall(require('telescope').load_extension, 'fzf')

    local root = string.gsub(vim.fn.system("git rev-parse --show-toplevel"), "\n", "")

    vim.keymap.set('n', '<leader>/', function() require('telescope.builtin').live_grep { cwd = root } end)

    vim.keymap.set('n', '<leader>#', function() require('telescope.builtin').grep_string { cwd = root } end)
    vim.keymap.set('n', '<leader><', function() require('telescope.builtin').oldfiles { cwd = root } end)
    vim.keymap.set('n', '<leader><space>', function() require('telescope.builtin').git_files { cwd = root } end)
end

return config
