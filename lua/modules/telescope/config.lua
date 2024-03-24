local config = {}

function config.setupTelescope()
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

function config.setupFzf()
    local fzf = require 'fzf-lua'

    local root = string.gsub(vim.fn.system("git rev-parse --show-toplevel"), "\n", "")

    vim.keymap.set('n', '<leader>/', function() fzf.live_grep { cwd = root, cmd = "git grep --line-number --column --color=always" } end)
    vim.keymap.set('n', '<leader>#', function() fzf.grep_cword { cwd = root } end)
    vim.keymap.set('n', '<leader><', function() fzf.oldfiles { cwd = root } end)

    vim.keymap.set('n', '<leader><space>', function() fzf.git_files { cwd = root } end)
end

return config
