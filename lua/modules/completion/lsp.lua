local lsp = {}

local lspconfig = require 'lspconfig'
-- local mason_lspconfig = require 'mason-lspconfig'
local configs = require 'lspconfig/configs'


local nmap = function(keys, func, desc)
    if desc then
        desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { desc = desc })
end

nmap('<leader>r', vim.lsp.buf.rename)
nmap('<leader>a', vim.lsp.buf.code_action, '[C]ode [A]ction')

nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
nmap('gd', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

-- TODO: autocmd for buffer
-- require('lspconfig').lua_ls.setup({
--   on_attach = function(client, bufnr)
--     -- Enable format on save
--     if client.server_capabilities.documentFormattingProvider then
--       local augroup = vim.api.nvim_create_augroup("LspFormat", { clear = true })
--       vim.api.nvim_create_autocmd("BufWritePre", {
--         group = augroup,
--         buffer = bufnr,
--         callback = function()
--           vim.lsp.buf.format({ bufnr = bufnr })
--         end,
--       })
--     end
--   end,
-- })


vim.g.format_on_save = true

vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    if vim.g.format_on_save then
      vim.lsp.buf.format()
    end
  end,
})

local function default_on_attach(_, bufnr)
    -- local fzf = require 'fzf-lua'
    -- nmap('gd', fzf.lsp_definitions, '[G]oto [D]efinition')
    -- nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
end


local mini_cmp = require 'modules.completion.cmp'
mini_cmp.setup(
    {
        delay = { completion = 100, info = 100, signature = 50 },

        window = {
            info = { height = 25, width = 80, border = nil },
            signature = { height = 25, width = 80, border = nil },
        },

        lsp_completion = {
            source_func = 'omnifunc',

            auto_setup = true,
        },

        fallback_action = '<C-n>',

        mappings = {
            force_twostep = '<C-Space>',
            force_fallback = '<A-Space>',
            scroll_down = nil,
            scroll_up = nil,
        },
    }
)

local function default_handlers()
    -- if not configs.golangcilsp then
    --     configs.golangcilsp = {
    --         default_config = {
    --             cmd = { 'golangci-lint-langserver' },
    --             root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
    --             init_options = {
    --                 -- command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json", "--issues-exit-code=1" };
    --                 command = { 'golangci-lint', 'run', '--out-format', 'json' },
    --             }
    --         },
    --     }
    -- end

    local capabilities = mini_cmp.get_lsp_capabilities()

    local on_attach = function (client, bufnr)
        mini_cmp.lsp_on_attach(client, bufnr)
    end

    vim.lsp.config["luals"] = {
        cmd = { 'lua-language-server' },
        filetypes = { 'lua' },
        root_markers = { { '.luarc.json', '.luarc.jsonc' }, '.git' },
        capabilities = capabilities,
        on_attach = on_attach,
        settings = {
            Lua = {

                workspace = {
                    checkThirdParty = false,
                    library = {
                        vim.env.VIMRUNTIME
                    }
                },

                runtime = {
                    version = 'LuaJIT',
                },

            }
        }
    }

    vim.lsp.enable("luals")


    local function set_python_path(path)
        local clients = vim.lsp.get_clients {
            bufnr = vim.api.nvim_get_current_buf(),
            name = 'pyright',
        }
        for _, client in ipairs(clients) do
            if client.settings then
                client.settings.python = vim.tbl_deep_extend('force', client.settings.python, { pythonPath = path })
            else
                client.config.settings = vim.tbl_deep_extend('force', client.config.settings, { python = { pythonPath = path } })
            end
            client.notify('workspace/didChangeConfiguration', { settings = nil })
        end
    end


    local function python_on_attach(client, bufnr)
        on_attach(client, bufnr)
        local function orginize_import()
            client:exec_cmd({
                command = 'pyright.organizeimports',
                arguments = { vim.uri_from_bufnr(bufnr) },
            })
        end

        vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightOrganizeImports', orginize_import, {
            desc = 'Organize Imports',
        })

        vim.api.nvim_buf_create_user_command(bufnr, 'LspPyrightSetPythonPath', set_python_path, {
            desc = 'Reconfigure pyright with the provided python path',
            nargs = 1,
            complete = 'file',
        })
    end


    vim.lsp.config["pyright"] = {
        cmd = { 'pyright-langserver', '--stdio' },
        filetypes = { 'python' },
        capabilities = capabilities,
        root_markers = {
            'pyproject.toml',
            'setup.py',
            'setup.cfg',
            'requirements.txt',
            'Pipfile',
            'pyrightconfig.json',
            '.git',
        },
        settings = {
            python = {
                analysis = {
                    autoSearchPaths = true,
                    useLibraryCodeForTypes = true,
                    diagnosticMode = 'workspace',
                    autoImportCompletions = true,
                    typeCheckingMode = "standard",
                    disableTaggedHints = true
                },
            },
        },
        on_attach = python_on_attach,
    }

    vim.lsp.enable("pyright")

    vim.lsp.config["ruff"] = {
        capabilities = capabilities,
        cmd = { 'ruff', 'server' },
        filetypes = { 'python' },
        root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
        settings = {},
        on_attach = on_attach,
    }
    vim.lsp.enable("ruff")


    -- lspconfig.golangci_lint_ls.setup {
    --     filetypes = { 'go', 'gomod' },
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    -- }
    --
    -- lspconfig.rnix.setup {}
    --
    --
    -- -- https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
    -- lspconfig['gopls'].setup {
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     settings = {
    --         gopls = {
    --             gofumpt = true,
    --             analyses = {
    --                 assign = true,
    --                 atomic = true,
    --                 bools = true,
    --                 composites = true,
    --                 copylocks = true,
    --                 deepequalerrors = true,
    --                 embed = true,
    --                 errorsas = true,
    --                 fieldalignment = false, -- lets you know about struct sizes
    --                 httpresponse = true,
    --                 ifaceassert = true,
    --                 loopclosure = true,
    --                 lostcancel = true,
    --                 nilfunc = true,
    --                 nilness = true,
    --                 nonewvars = true,
    --                 printf = true,
    --                 shadow = true, -- lets you know about duplicate err declerations
    --                 shift = true,
    --                 simplifycompositelit = true,
    --                 simplifyrange = true,
    --                 simplifyslice = true,
    --                 sortslice = true,
    --                 stdmethods = true,
    --                 stringintconv = true,
    --                 structtag = true,
    --                 testinggoroutine = true,
    --                 tests = true,
    --                 timeformat = true,
    --                 unmarshal = true,
    --                 unreachable = true,
    --                 unsafeptr = true,
    --                 unusedparams = true,
    --                 unusedresult = true,
    --                 unusedvariable = true,
    --                 unusedwrite = true,
    --                 useany = true,
    --             },
    --             hoverKind = "FullDocumentation",
    --             linkTarget = "pkg.go.dev",
    --             usePlaceholders = true,
    --             vulncheck = "Imports",
    --         },
    --     },
    -- }
    --
    -- -- lspconfig.efm.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- --     init_options = { documentFormatting = true },
    -- --     settings = {
    -- --         languages = {
    -- --             -- css = {
    -- --             --     { formatCommand = 'prettier "${INPUT}"', formatStdin = true, }
    -- --             -- },
    -- --             -- scss = {
    -- --             --     { formatCommand = 'prettier "${INPUT}"', formatStdin = true, }
    -- --             -- }
    -- --         }
    -- --     }
    -- -- }
    --
    -- -- lspconfig.eslint.setup {
    -- --     capabilities = capabilities,
    -- --     root_dir = require 'lspconfig/util'.root_pattern(
    -- --     '.eslintrc',
    -- --     '.eslintrc.js',
    -- --     '.eslintrc.cjs',
    -- --     '.eslintrc.yaml',
    -- --     '.eslintrc.yml',
    -- --     '.eslintrc.json',
    -- --     'package.json',
    -- --     '.git'
    -- --     ),
    -- --     on_attach = function(_, bufnr)
    -- --         vim.api.nvim_create_autocmd("BufWritePre", {
    -- --             buffer = bufnr,
    -- --             command = "EslintFixAll",
    -- --         })
    -- --     end,
    -- -- }
    -- lspconfig.lua_ls.setup {
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     on_init = function(client)
    --         if client.workspace_folders then
    --             local path = client.workspace_folders[1].name
    --             if
    --                 path ~= vim.fn.stdpath('config')
    --                 and (vim.uv.fs_stat(path .. '/.luarc.json') or vim.uv.fs_stat(path .. '/.luarc.jsonc'))
    --             then
    --                 return
    --             end
    --         end
    --
    --         client.config.settings.Lua = vim.tbl_deep_extend('force', client.config.settings.Lua, {
    --             runtime = {
    --                 -- Tell the language server which version of Lua you're using (most
    --                 -- likely LuaJIT in the case of Neovim)
    --                 version = 'LuaJIT',
    --                 -- Tell the language server how to find Lua modules same way as Neovim
    --                 -- (see `:h lua-module-load`)
    --                 path = {
    --                     'lua/?.lua',
    --                     'lua/?/init.lua',
    --                 },
    --             },
    --             -- Make the server aware of Neovim runtime files
    --             workspace = {
    --                 checkThirdParty = false,
    --                 library = {
    --                     vim.env.VIMRUNTIME
    --                     -- Depending on the usage, you might want to add additional paths
    --                     -- here.
    --                     -- '${3rd}/luv/library'
    --                     -- '${3rd}/busted/library'
    --                 }
    --                 -- Or pull in all of 'runtimepath'.
    --                 -- NOTE: this is a lot slower and will cause issues when working on
    --                 -- your own configuration.
    --                 -- See https://github.com/neovim/nvim-lspconfig/issues/3189
    --                 -- library = {
    --                 --   vim.api.nvim_get_runtime_file('', true),
    --                 -- }
    --             }
    --         })
    --     end,
    --     settings = {
    --         Lua = {
    --             workspace = { checkThirdParty = false },
    --             telemetry = { enable = false },
    --         },
    --     }
    -- }
    --
    -- lspconfig.ts_ls.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    -- })
    --
    --
    -- lspconfig.jsonls.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    -- })
    --
    -- lspconfig.cssls.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     settings = {
    --         css = {
    --             validate = true
    --         },
    --         less = {
    --             validate = true
    --         },
    --         scss = {
    --             validate = true
    --         }
    --     }
    -- })
    --
    -- lspconfig.html.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     settings = { filetypes = { 'html', 'twig', 'hbs' } },
    -- })
    --
    -- lspconfig.svelte.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    -- })
    --
    -- lspconfig.pyright.setup {
    --     capabilities = capabilities,
    --     -- on_attach = function(client, bufnr)
    --     --     default_on_attach(client, bufnr)
    --     -- end,
    --     -- settings = {
    --     --     -- python = {
    --     --     --     analysis = {
    --     --     --         -- Ignore all files for analysis to exclusively use Ruff for linting
    --     --     --         ignore = { '*' },
    --     --     --     },
    --     --     -- },
    --     --     -- pyright = {
    --     --     --     -- Using Ruff's import organizer
    --     --     --     -- disableOrganizeImports = true,
    --     --     -- },
    --     --
    --     --     -- basedpyright = {
    --     --     --     analysis = {
    --     --     --         typeCheckingMode = "basic",
    --     --     --         autoImportCompletions = true,
    --     --     --         diagnosticSeverityOverrides = {
    --     --     --             reportUnusedImport = "information",
    --     --     --             reportUnusedFunction = "information",
    --     --     --             reportUnusedVariable = "information",
    --     --     --             reportGeneralTypeIssues = "none",
    --     --     --             reportOptionalMemberAccess = "none",
    --     --     --             reportOptionalSubscript = "none",
    --     --     --             reportPrivateImportUsage = "none",
    --     --     --         },
    --     --     --     },
    --     --     -- }
    --     -- }
    -- }
    --
    -- -- require('lspconfig').ruff.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = function(client, bufnr)
    -- --         default_on_attach(client, bufnr)
    -- --         client.server_capabilities.hoverProvider = false
    -- --     end,
    -- --     init_options = {
    -- --         settings = {
    -- --             logLevel = 'debug',
    -- --             args = {},
    -- --         }
    -- --     }
    -- -- }
    --
    -- -- require('lspconfig').ruff_lsp.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = function(client, bufnr)
    -- --         default_on_attach(client, bufnr)
    -- --         client.server_capabilities.hoverProvider = false
    -- --     end,
    -- --     -- settings = {
    -- --     -- },
    -- --     init_options = {
    -- --         settings = {
    -- --             logLevel = 'debug',
    -- --             args = {
    -- --             },
    -- --
    -- --         }
    -- --     }
    -- -- }
    --
    -- -- local function add_ruby_deps_command(client, bufnr)
    -- --     vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
    -- --             local params = vim.lsp.util.make_text_document_params()
    -- --             local showAll = opts.args == "all"
    -- --
    -- --             client.request("rubyLsp/workspace/dependencies", params, function(error, result)
    -- --                 if error then
    -- --                     print("Error showing deps: " .. error)
    -- --                     return
    -- --                 end
    -- --
    -- --                 local qf_list = {}
    -- --                 for _, item in ipairs(result) do
    -- --                     if showAll or item.dependency then
    -- --                         table.insert(qf_list, {
    -- --                             text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),
    -- --                             filename = item.path
    -- --                         })
    -- --                     end
    -- --                 end
    -- --
    -- --                 vim.fn.setqflist(qf_list)
    -- --                 vim.cmd('copen')
    -- --             end, bufnr)
    -- --         end,
    -- --         { nargs = "?", complete = function() return { "all" } end })
    -- -- end
    --
    -- -- lspconfig.ruby_lsp.setup {
    -- --     cmd = { "bundle", "exec", "ruby-lsp" },
    -- --     init_options = {
    -- --         formatter = 'standard',
    -- --         linters = { 'standard' },
    -- --     },
    -- --     capabilities = capabilities,
    -- --     on_attach = function(client, bufnr)
    -- --         default_on_attach(client, bufnr)
    -- --         add_ruby_deps_command(client, bufnr)
    -- --     end
    -- -- }
    -- --
    -- --
    -- -- lspconfig.solargraph.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- --     cmd = { "bundle", "exec", "solargraph", "stdio" },
    -- --     init_options = {
    -- --         completion = true,
    -- --         diagnostic = true,
    -- --         folding = true,
    -- --         references = true,
    -- --         rename = true,
    -- --         symbols = true
    -- --     },
    -- -- }
    --
    -- -- lspconfig.docker_compose_language_service.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- --     -- settings = {  },
    -- -- }
    --
    -- -- lspconfig.dockerls.setup({
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- -- })
    --
    -- -- lspconfig.graphql.setup({
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- -- })
    --
    -- -- lspconfig.ccls.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- --     init_options = {
    -- --         -- https://github.com/MaskRay/ccls/wiki/Customization#compilationdatabasedirectory
    -- --         compilationDatabaseDirectory = "builddir",
    -- --         index = {
    -- --             threads = 0,
    -- --         },
    -- --         clang = {
    -- --             excludeArgs = { "-frounding-math" },
    -- --         },
    -- --     }
    -- -- }
    --
    -- -- rustup component add rust-analyzer
    -- lspconfig.rust_analyzer.setup {
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     settings = {
    --         ['rust-analyzer'] = {
    --             -- imports = {
    --             --     granularity = {
    --             --         group = "module",
    --             --     },
    --             --     prefix = "self",
    --             -- },
    --             -- cargo = {
    --             --     buildScripts = {
    --             --         enable = true,
    --             --     },
    --             -- },
    --             -- procMacro = {
    --             --     enable = true
    --             -- },
    --         }
    --     }
    -- }
    --
    -- -- lspconfig.zls.setup {
    -- --     capabilities = capabilities,
    -- --     on_attach = default_on_attach,
    -- -- }
    --
    -- lspconfig.volar.setup {
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' }
    -- }
end

function lsp.setup()

    vim.opt.wildmode = "longest:full,full"
    vim.opt.completeopt = "menu,menuone,noselect"

    local function has_words_before()
        local _line, col = unpack(vim.api.nvim_win_get_cursor(0))
        return col ~= 0 and vim.api.nvim_get_current_line():sub(col, col):match("%s") == nil
    end

    vim.keymap.set('i', '<Tab>', function()
        if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes('<C-n>', true, true, true)
        elseif has_words_before() then
            return vim.api.nvim_replace_termcodes('<C-x><C-o>', true, true, true) -- optionally trigger completion
        else
            return '\t'
        end
    end, { expr = true, silent = true })

    vim.keymap.set('i', '<S-Tab>', function()
        if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes('<C-p>', true, true, true)
        else
            return '\t'
        end
    end, { expr = true, silent = true })

    vim.keymap.set('i', '<CR>', function()
        if vim.fn.pumvisible() == 1 then
            return vim.api.nvim_replace_termcodes('<C-y>', true, true, true)
        else
            return vim.api.nvim_replace_termcodes('<CR>', true, true, true)
        end
    end, { expr = true, silent = true })

    -- require 'mason'.setup()
    -- require 'mason-lspconfig'.setup()
    default_handlers()
end

return lsp
