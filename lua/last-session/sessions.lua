local utils = require('last-session.utils')
local config = require('last-session.config')

local M = {}

-- Save current opened buffer list
M.save_session = function()

	-- check session_file is existed and make it if not
	local session_dir = vim.fn.fnamemodify(config.path, ':h')
	local session_file = config.path
	utils.check_dir(session_dir)


	-- get list of opened buffers
	local buffers = vim.api.nvim_list_bufs() -- get all buffer list
	local file_list = {}

	for _, bufnr in ipairs(buffers) do -- get buffer number
		if vim.api.nvim_buf_is_loaded(bufnr) then -- check the buffer is opened
			local file = utils.filter_ignored(bufnr)
			if file then
				table.insert(file_list, file)
			end
		end
	end

	local success = pcall(function()
		vim.fn.writefile(file_list, session_file)
	end)

	if success then
		print('Session saved to ' .. session_file)
	else
		print('Error: Could not write to session file')
	end
end

-- Restore last session
M.restore_session = function()
	local session_file = config.path

	if vim.fn.filereadable(session_file) == 1 then
		local files = vim.fn.readfile(session_file)
		if files then
			for _, file in ipairs(files) do
				if vim.fn.filereadable(file) == 1 then
					vim.cmd('edit ' .. vim.fn.fnameescape(file))
				end
			end
		else
			print('Error: Could not read session file')
		end
	else
		print('No session file found at ' .. session_file)
	end
end

return M
