local global = {}

function global:load_variables()
    local home = os.getenv('HOME') or vim.fn.expand('$HOME')
    local os_name = vim.loop.os_uname().sysname
    self.is_mac = os_name == 'Darwin'
    self.is_linux = os_name == 'Linux'
    self.is_windows = os_name:find('Windows') ~= nil or os_name:find('MINGW')
    if self.is_windows then
        self.is_mingw = false
    end
    self.path_sep = global.is_windows and '\\' or '/'
    self.vim_path = vim.fn.stdpath('config')
end

global:load_variables()

return global
