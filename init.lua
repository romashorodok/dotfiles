
local lua_directory = '/Users/user/my-nvim'

vim.o.runtimepath = vim.o.runtimepath .. ',' .. lua_directory

require('core')

