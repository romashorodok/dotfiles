local lsp = {}

local lspconfig = require 'lspconfig'
local mason_lspconfig = require 'mason-lspconfig'
local configs = require 'lspconfig/configs'

local function default_on_attach(_, bufnr)
    local nmap = function(keys, func, desc)
        if desc then
            desc = 'LSP: ' .. desc
        end

        vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
    end

    nmap('<leader>cr', vim.lsp.buf.rename)
    nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')
    nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
    nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')
    nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')

    local fzf = require 'fzf-lua'
    nmap('gd', fzf.lsp_definitions, '[G]oto [D]efinition')
    -- nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
end

local function default_handlers()
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    if not configs.golangcilsp then
        configs.golangcilsp = {
            default_config = {
                cmd = { 'golangci-lint-langserver' },
                root_dir = lspconfig.util.root_pattern('.git', 'go.mod'),
                init_options = {
                    -- command = { "golangci-lint", "run", "--enable-all", "--disable", "lll", "--out-format", "json", "--issues-exit-code=1" };
                    command = { 'golangci-lint', 'run', '--out-format', 'json' },
                }
            },
        }
    end

    lspconfig.golangci_lint_ls.setup {
        filetypes = { 'go', 'gomod' },
        capabilities = capabilities,
        on_attach = default_on_attach,
    }

    lspconfig.rnix.setup {}


    -- https://github.com/golang/tools/blob/master/gopls/doc/analyzers.md
    lspconfig['gopls'].setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        settings = {
            gopls = {
                gofumpt = true,
                analyses = {
                    assign = true,
                    atomic = true,
                    bools = true,
                    composites = true,
                    copylocks = true,
                    deepequalerrors = true,
                    embed = true,
                    errorsas = true,
                    fieldalignment = false, -- lets you know about struct sizes
                    httpresponse = true,
                    ifaceassert = true,
                    loopclosure = true,
                    lostcancel = true,
                    nilfunc = true,
                    nilness = true,
                    nonewvars = true,
                    printf = true,
                    shadow = true, -- lets you know about duplicate err declerations
                    shift = true,
                    simplifycompositelit = true,
                    simplifyrange = true,
                    simplifyslice = true,
                    sortslice = true,
                    stdmethods = true,
                    stringintconv = true,
                    structtag = true,
                    testinggoroutine = true,
                    tests = true,
                    timeformat = true,
                    unmarshal = true,
                    unreachable = true,
                    unsafeptr = true,
                    unusedparams = true,
                    unusedresult = true,
                    unusedvariable = true,
                    unusedwrite = true,
                    useany = true,
                },
                hoverKind = "FullDocumentation",
                linkTarget = "pkg.go.dev",
                usePlaceholders = true,
                vulncheck = "Imports",
            },
        },
    }

    -- lspconfig.efm.setup {
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     init_options = { documentFormatting = true },
    --     settings = {
    --         languages = {
    --             -- css = {
    --             --     { formatCommand = 'prettier "${INPUT}"', formatStdin = true, }
    --             -- },
    --             -- scss = {
    --             --     { formatCommand = 'prettier "${INPUT}"', formatStdin = true, }
    --             -- }
    --         }
    --     }
    -- }

    -- lspconfig.eslint.setup {
    --     capabilities = capabilities,
    --     root_dir = require 'lspconfig/util'.root_pattern(
    --     '.eslintrc',
    --     '.eslintrc.js',
    --     '.eslintrc.cjs',
    --     '.eslintrc.yaml',
    --     '.eslintrc.yml',
    --     '.eslintrc.json',
    --     'package.json',
    --     '.git'
    --     ),
    --     on_attach = function(_, bufnr)
    --         vim.api.nvim_create_autocmd("BufWritePre", {
    --             buffer = bufnr,
    --             command = "EslintFixAll",
    --         })
    --     end,
    -- }

    lspconfig.ts_ls.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })


    lspconfig.jsonls.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })

    lspconfig.cssls.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
        settings = {
            css = {
                validate = true
            },
            less = {
                validate = true
            },
            scss = {
                validate = true
            }
        }
    })

    lspconfig.html.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
        settings = { filetypes = { 'html', 'twig', 'hbs' } },
    })

    lspconfig.svelte.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })

    on_attach = function(client, bufnr)

    end

    lspconfig.pyright.setup {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            default_on_attach(client, bufnr)
        end,
        settings = {
            -- python = {
            --     analysis = {
            --         -- Ignore all files for analysis to exclusively use Ruff for linting
            --         ignore = { '*' },
            --     },
            -- },
            pyright = {
                -- Using Ruff's import organizer
                -- disableOrganizeImports = true,
            },
            -- basedpyright = {
            --     analysis = {
            --         typeCheckingMode = "basic",
            --         autoImportCompletions = true,
            --         diagnosticSeverityOverrides = {
            --             reportUnusedImport = "information",
            --             reportUnusedFunction = "information",
            --             reportUnusedVariable = "information",
            --             reportGeneralTypeIssues = "none",
            --             reportOptionalMemberAccess = "none",
            --             reportOptionalSubscript = "none",
            --             reportPrivateImportUsage = "none",
            --         },
            --     },
            -- }
        }
    }


    require('lspconfig').ruff_lsp.setup {
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            default_on_attach(client, bufnr)
            client.server_capabilities.hoverProvider = false
        end,
        -- settings = {
        -- },
        init_options = {
            settings = {
                logLevel = 'debug',
                args = {
                },

            }
        }
    }

    local function add_ruby_deps_command(client, bufnr)
        vim.api.nvim_buf_create_user_command(bufnr, "ShowRubyDeps", function(opts)
                local params = vim.lsp.util.make_text_document_params()
                local showAll = opts.args == "all"

                client.request("rubyLsp/workspace/dependencies", params, function(error, result)
                    if error then
                        print("Error showing deps: " .. error)
                        return
                    end

                    local qf_list = {}
                    for _, item in ipairs(result) do
                        if showAll or item.dependency then
                            table.insert(qf_list, {
                                text = string.format("%s (%s) - %s", item.name, item.version, item.dependency),
                                filename = item.path
                            })
                        end
                    end

                    vim.fn.setqflist(qf_list)
                    vim.cmd('copen')
                end, bufnr)
            end,
            { nargs = "?", complete = function() return { "all" } end })
    end


    lspconfig.ruby_lsp.setup {
        cmd = { "bundle", "exec", "ruby-lsp" },
        init_options = {
            formatter = 'standard',
            linters = { 'standard' },
        },
        capabilities = capabilities,
        on_attach = function(client, bufnr)
            default_on_attach(client, bufnr)
            add_ruby_deps_command(client, bufnr)
        end
    }


    lspconfig.solargraph.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        cmd = { "bundle", "exec", "solargraph", "stdio" },
        init_options = {
            completion = true,
            diagnostic = true,
            folding = true,
            references = true,
            rename = true,
            symbols = true
        },
    }

    -- TODO: not works
    -- lspconfig.docker_compose_language_service.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     settings = { filetypes = { 'yaml.docker-compose' }, },
    -- })

    lspconfig.docker_compose_language_service.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        -- settings = {  },
    }

    lspconfig.dockerls.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })

    lspconfig.graphql.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })

    lspconfig.ccls.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        init_options = {
            -- https://github.com/MaskRay/ccls/wiki/Customization#compilationdatabasedirectory
            compilationDatabaseDirectory = "builddir",
            index = {
                threads = 0,
            },
            clang = {
                excludeArgs = { "-frounding-math" },
            },
        }
    }

    -- rustup component add rust-analyzer
    -- rustup component add rust-analyzer
    lspconfig.rust_analyzer.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        settings = {
            ['rust-analyzer'] = {
                -- imports = {
                --     granularity = {
                --         group = "module",
                --     },
                --     prefix = "self",
                -- },
                -- cargo = {
                --     buildScripts = {
                --         enable = true,
                --     },
                -- },
                -- procMacro = {
                --     enable = true
                -- },
            }
        }
    }

    lspconfig.zls.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
    }

    lspconfig.volar.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        filetypes = { 'typescript', 'javascript', 'javascriptreact', 'typescriptreact', 'vue', 'json' }
    }
end

local function ensure_installed()
    mason_lspconfig.setup {
        ensure_installed = {
            -- 'cssls',
            -- 'html',
            -- 'jsonls',
            -- 'tsserver',
            -- 'eslint',
            -- 'efm',
            -- 'svelte',
            'docker_compose_language_service',
            'dockerls',
            -- 'graphql',
            'pyright',
            -- 'solargraph',
        }
    }
end

function lsp.setup()
    require 'mason'.setup()
    require 'mason-lspconfig'.setup()
    ensure_installed()
    default_handlers()
end

function lsp.setup_handlers(servers, on_attach)
    local capabilities = vim.lsp.protocol.make_client_capabilities()
    capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)

    mason_lspconfig.setup {
        ensure_installed = vim.tbl_keys(servers)
    }

    mason_lspconfig.setup_handlers {
        function(server_name)
            lspconfig[server_name].setup {
                capabilities = capabilities,
                on_attach = function(client, bufnr)
                    default_on_attach(client, bufnr)
                    on_attach(client, bufnr)
                end,
                settings = servers[server_name],
                filetypes = (servers[server_name] or {}).filetypes,
            }
        end
    }
end

return lsp
