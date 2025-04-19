local config = require('last-session.config')
local utils = require('last-session.utils')

local M = {}

-- change separator depends on OS
local isWin = vim.fn.has('win32')
local sep1, sep2 = '\\', '/'
if isWin == 1 then
	sep1, sep2 = '/', '\\'
end

-- Save current opened buffer list
M.save_session = function()
	local options = config.get_config()

	-- check session_file is existed and make it if not
	local session_dir = vim.fn.fnamemodify(options.path, ':h')
	local session_file = options.path
	utils.check_dir(session_dir)


	-- get list of opened buffers
	local focused_bufnr = vim.api.nvim_get_current_buf() -- get focused file buffer number
	local buffers = vim.api.nvim_list_bufs()             -- get all buffer number list
	local session_data = {}                              -- total file_data list of opened buffer

	for _, bufnr in ipairs(buffers) do -- get buffer number
		if vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_buf_get_option(bufnr, 'buflisted') then -- check the buffer is opened
			local file_path = utils.filter_ignored(bufnr)
			if file_path then
				local file_data = { -- window data of opened buffer
					bufnr   = bufnr,
					focused = bufnr == focused_bufnr and 1 or 0,
					path    = file_path:gsub(sep1, sep2) -- unify the separator
				}
				table.insert(session_data, file_data)
			end
		end
	end

	-- save session
	local success = pcall(function()
		vim.fn.writefile({vim.json.encode(session_data)}, session_file)
	end)

	if success then
		print('Session saved to ' .. session_file)
	else
		vim.api.nvim_echo({{'Error: Could not write to session file'}}, false, {err = true})
	end
end

-- Restore last session
M.load_session = function()
	local options = config.get_config()
	local session_file = options.path

	-- check if session file is exists
	if vim.fn.filereadable(session_file) ~= 1 then
		vim.api.nvim_echo({{'No session file found at ' .. session_file}}, false, {err = true})
		return
	end

	-- check if session file contents is empty
	local lines = vim.fn.readfile(session_file)
	if not lines and #lines == 0 then
		vim.api.nvim_echo({{'Error: Could not read session file'}}, false, {err = true})
		return
	end

	-- decode session file contents
	local ok, session_data = pcall(vim.json.decode, lines[1])
	if not ok then
		vim.api.nvim_echo({{'Error: Invalid session file format'}}, false, {err = true})
		return
	end

	-- load buffers
	for _, file_data in ipairs(session_data) do
		if vim.fn.filereadable(file_data.path) == 1 then
			-- edit only focused file to fast load
			local cmd_open = file_data.focused == 1 and 'edit' or 'badd'
			vim.cmd(cmd_open .. vim.fn.fnameescape(file_data.path))
		end
	end
end

return M
