local sessions = require('last-session.sessions')

local M = {}

-- default configuration
local default_config = {
	auto_save    = false, -- save last session automatically when VimLeave
	path         = vim.fn.stdpath('data') .. '/last-session/last-session.txt',
	ignored_list = {
		ignored_type = {},    -- List of file extensions or filetypes to ignore
		ignored_dir  = {},    -- List of directory path patterns to ignore
	}
}

M.config = nil

-- setup
M.setup = function(opts)
	opts = opts or {}

	M.config = vim.tbl_extend('force', default_config, opts or {})

	-- If auto_save is true, save the session before exiting Neovim.
	if M.config.auto_save then
		vim.api.nvim_create_autocmd('VimLeavePre', {
			group = vim.api.nvim_create_augroup('LastSession', { clear = true }),
			callback = function ()
				sessions.save_session()
			end,
			desc = 'Auto-save session before exiting Neovim',
		})
	end
end

return M
