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

	local has_focused = false
	for _, bufnr in ipairs(buffers) do -- get buffer number
		if vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_get_option_value('buflisted', {buf = bufnr}) then -- check the buffer is opened
			local file_path = utils.filter_ignored(bufnr)
			if file_path then
				local file_data = { -- window data of opened buffer
					bufnr   = bufnr,
					focused = bufnr == focused_bufnr and 1 or 0,
					path    = file_path:gsub(sep1, sep2) -- unify the separator
				}
				if file_data.focused == 1 then
					has_focused = true
				end
				table.insert(session_data, file_data)
			end
		end
	end

	-- if there is no focused file, first file is focused
	if not has_focused and #session_data > 0 then
		session_data[1].focused = 1
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
		vim.api.nvim_echo({{'Error: No session file found at ' .. session_file}}, false, {err = true})
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
			local cmd_open = file_data.focused == 1 and 'edit ' or 'badd '
			vim.cmd(cmd_open .. vim.fn.fnameescape(file_data.path))
		end
	end
end

-- View last-session file
M.view_session = function ()
	local options = config.get_config()
    local session_file = options.path

    -- Check whether session_file exists
    if vim.fn.filereadable(session_file) ~= 1 then
        vim.api.nvim_echo({{'Error: No session file: ' .. session_file}}, false, {err = true})
        return
    end

    -- Check whether 'jq' is installed
    if not vim.fn.executable('jq') then
        vim.api.nvim_echo({{'Error: jq not installed'}}, false, {err = true})
        return
    end

    -- create new buffer
    local bufnr = vim.api.nvim_create_buf(false, true) -- 스크래치 버퍼, nobuflisted
    -- vim.api.nvim_buf_set_name(bufnr, '[Last Session JSON]')
    vim.api.nvim_buf_set_name(bufnr, '[View] ' .. vim.fn.fnamemodify(session_file, ':~'))

    -- read output of jq
    local output = vim.fn.systemlist('jq . ' .. vim.fn.shellescape(session_file))
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{'Error: jq failed to read ' .. session_file}}, false, {err = true})
        vim.api.nvim_buf_delete(bufnr, { force = true })
        return
    end

	-- remove carriage return
	for i, line in ipairs(output) do
		output[i] = line:gsub('\r', '')
	end

    -- write the contents to buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
	vim.api.nvim_set_option_value('filetype', 'json', { buf = bufnr })
	vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
	vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    -- set new keymap for current buffer
    vim.keymap.set('n', 'q', ':bd<CR>', { buffer = bufnr, noremap = true, silent = true })
end


return M
