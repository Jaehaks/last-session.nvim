-- default configuration
local M = {
	auto_save    = false, -- save last session automatically when VimLeave
	path         = vim.fn.stdpath('data') .. '/last-session/last-session.txt',
	ignored_list = {
		ignored_type = {},    -- List of file extensions or filetypes to ignore
		ignored_dir  = {},    -- List of directory path patterns to ignore
	}
}

return M
