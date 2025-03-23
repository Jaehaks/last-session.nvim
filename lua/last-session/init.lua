local config = require('last-session.config')
local sessions = require('last-session.sessions')

local M = {}

M.config = nil

-- setup
M.setup = function(opts)
	opts = opts or {}

	M.config = vim.tbl_extend('force', config, opts or {})

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
