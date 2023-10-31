local lazy = {}
lazy.__index = lazy
local global = require'core.global'
local sep = global.path_sep
local config = global.vim_path
local win = global.is_windows

function lazy.add(repo)
  if not lazy.plug then
    lazy.plug = {}
  end
  if repo.lazy == nil then
    repo.lazy = true
  end
  table.insert(lazy.plug, repo)
end

function lazy:modules()
    if not win then
        vim.loader.enable()
    end

    local modules = config .. sep .. 'lua' .. sep .. 'modules'
    local plugins_list = {
        modules .. sep .. 'completion' .. sep .. 'plugins.lua',
        modules .. sep .. 'lua' .. sep .. 'plugins.lua',
    }
    for _, f in pairs(plugins_list) do
        local _, pos = f:find(modules)
        if pos then
            f = f:sub(pos - 6, #f - 4)
        end

        local plugins = require(f)
        plugins(lazy.add)
    end
end

function lazy:bootstrap()
    local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"

    if not vim.loop.fs_stat(lazypath) then
        vim.fn.system({
            "git",
            "clone",
            "--filter=blob:none",
            "https://github.com/folke/lazy.nvim.git",
            "--branch=stable",
            lazypath,
        })
    end

    vim.opt.rtp:prepend(lazypath)

    local lz = require('lazy')

    self:modules()

    lz.setup(self.plug, {
        lockfile = config .. sep .. 'lazy-lock.json'
    })
end

return lazy
