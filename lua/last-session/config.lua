local M = {}

-- default configuration
local default_config = {
	auto_save    = false, -- save last session automatically when VimLeave
	path         = vim.fn.stdpath('data') .. '/last-session/last-session.json',
	ignored_list = {
		ignored_type = {},    -- List of file extensions or filetypes to ignore
		ignored_dir  = {},    -- List of directory path patterns to ignore
	}
}

local config = vim.deepcopy(default_config)

M.get_config = function ()
	return config
end

M.setup = function (opts)
	config = vim.tbl_deep_extend('force', default_config, opts or {})
end

return M
