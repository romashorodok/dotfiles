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
    nmap('gd', require('telescope.builtin').lsp_definitions, '[G]oto [D]efinition')
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

    lspconfig.efm.setup {
        capabilities = capabilities,
        on_attach = default_on_attach,
        init_options = { documentFormatting = true },
        settings = {
            languages = {
                css = {
                    { formatCommand = 'prettier "${INPUT}"', formatStdin = true, }
                },
                scss = {
                    { formatCommand = 'prettier "${INPUT}"', formatStdin = true, }
                }
            }
        }
    }

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

    lspconfig.tsserver.setup({
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

    -- TODO: not works
    -- lspconfig.docker_compose_language_service.setup({
    --     capabilities = capabilities,
    --     on_attach = default_on_attach,
    --     settings = { filetypes = { 'yaml.docker-compose' }, },
    -- })

    lspconfig.dockerls.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })

    lspconfig.graphql.setup({
        capabilities = capabilities,
        on_attach = default_on_attach,
    })
end

local function ensure_installed()
    mason_lspconfig.setup {
        ensure_installed = {
            'cssls',
            'html',
            'jsonls',
            'tsserver',
            'eslint',
            'efm',
            'svelte',
            'docker_compose_language_service',
            'dockerls',
            'graphql',
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
