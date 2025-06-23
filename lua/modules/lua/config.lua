local config = {}

local servers = {
    lua_ls = {
        Lua = {
            workspace = { checkThirdParty = false },
            telemetry = { enable = false },
        },
    }
}

local function on_attach(_, _)
end

function config.setup()
    require'neodev'.setup()
    -- require'modules.completion.lsp'.setup_handlers(servers, on_attach)
end

return config
