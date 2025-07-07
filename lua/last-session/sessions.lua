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

	-- delete ignored buffer
	local buffers = {}
	local buflist = vim.api.nvim_list_bufs()             -- get all buffer number list
	for _, bufnr in pairs(buflist) do
		local file_path = utils.filter_ignored(bufnr)
		if not file_path then
			vim.api.nvim_buf_delete(bufnr, {unload = true})
		elseif file_path == "" then
			-- if file name doesn't exist like dashboard, it is ignored to insert save table
		else
			table.insert(buffers, bufnr)
		end
	end

	-- if table is empty, don't save session file
	if #buffers == 0 then
		return
	end

	-- get list of opened buffers
	local session_data = {                               -- total file_data list of opened buffer
		buffers = {},                                    -- opened buffer data
		windows = {},                                    -- window data
		layout = vim.fn.winlayout()                      -- row/col Hierarchy
	}

	for _, bufnr in ipairs(buffers) do -- get buffer number
		local file_path = vim.api.nvim_buf_get_name(bufnr) -- get absolute path
		-- save buffer information
		local file_data = {
			bufnr   = bufnr,
			path    = file_path:gsub(sep1, sep2), -- unify the separator
		}
		table.insert(session_data.buffers, file_data)
	end

	-- get current window layout
	local has_focused = false
	local focused_winid = vim.api.nvim_get_current_win() -- get focused winid
	local wins = vim.api.nvim_list_wins() -- get all winid
	for _, winid in ipairs(wins) do
		local bufnr = vim.api.nvim_win_get_buf(winid)
		local winnum = vim.api.nvim_win_get_number(winid)
		local curosr = vim.api.nvim_win_get_cursor(winid)
		local topline = vim.fn.line('w0', winid)
		local bufidx = utils.get_bufidx(bufnr, session_data.buffers)
		local win_data = {
			winid = winid,
			winnum = winnum,
			bufnr = bufnr,
			bufidx = bufidx,
			focused = winid == focused_winid and 1 or 0,
			cursor = {
				line = curosr[1],
				col = curosr[2],
			},
			topline = topline,
		}

		-- check win_data is valid. Sometimes nvim_list_wins() includes invisible [SCRATCH] buffer
		local file_path = utils.filter_ignored(bufnr)
		if not file_path or #file_path > 0 then
			table.insert(session_data.windows, win_data)
		end

		if win_data.focused == 1 then
			has_focused = true
		end
	end



	-- if there is no focused file, first file is focused
	if not has_focused and #session_data > 0 then
		session_data.windows[1].focused = 1
	end

	-- save session
	local success = pcall(function()
		vim.fn.writefile({vim.json.encode(session_data)}, session_file)
	end)

	if success then
		vim.notify('Session saved to ' .. session_file, vim.log.levels.INFO )
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

	-- delete current session
	local buflist = vim.api.nvim_list_bufs()             -- get all buffer number list
	for _, bufnr in pairs(buflist) do
		vim.api.nvim_buf_delete(bufnr, {unload = true})
	end

	-- load buffers
	for i, file_data in ipairs(session_data.buffers) do
		if vim.fn.filereadable(file_data.path) == 1 then
			-- add all session buffers with unload state
			local bufnr = vim.fn.bufadd(file_data.path)
			vim.api.nvim_set_option_value('buflisted', true, {buf = bufnr})
			session_data.buffers[i].bufnr = bufnr
		end
	end

	-- check the session data is valid
	if #session_data.buffers == 0 then
		vim.notify('Last-session : There are no saved session', vim.log.levels.WARN )
		return
	end

	-- set layout
	local function create_layout(layout)
		if layout[1] == 'row' or layout[1] == 'col' then
			local split_cmd = layout[1] == 'row' and 'vsplit' or 'split'
			local child = layout[2]

			create_layout(child[1])
			for i = 2, #child do
				vim.cmd(split_cmd)
				create_layout(child[i])
			end
		end
	end
	create_layout(session_data.layout)

	-- open visible buffer
	local focused_winid = 0
	for _, win_data in ipairs(session_data.windows) do
		local winid = vim.fn.win_getid(win_data.winnum)
		local bufnr = session_data.buffers[win_data.bufidx].bufnr
		vim.api.nvim_win_set_buf(winid, bufnr)
		vim.api.nvim_win_set_cursor(winid, {win_data.cursor.line, win_data.cursor.col})
		vim.api.nvim_set_current_win(winid)
		vim.fn.winrestview({topline = win_data.topline}) -- winrestview needs to set current win
		if win_data.focused == 1 then
			focused_winid = winid
		end
		-- vim.print({winid, bufnr, win_data.cursor, win_data.topline})
	end
	vim.api.nvim_set_current_win(focused_winid)
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

    -- read output of jq
    local output = vim.fn.systemlist('jq . ' .. vim.fn.shellescape(session_file))
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({{'Error: jq failed to read ' .. session_file}}, false, {err = true})
        return
    end

	-- remove carriage return
	for i, line in ipairs(output) do
		output[i] = line:gsub('\r', '')
	end

    -- create new buffer
	vim.cmd('tabnew') -- [No Name] buffer is created after new tab
	local winid = vim.api.nvim_get_current_win()
	local old_bufnr = vim.api.nvim_get_current_buf()
    local bufnr = vim.api.nvim_create_buf(false, true) -- scratched buffer, nobuflisted
    vim.api.nvim_buf_set_name(bufnr, '[View] ' .. vim.fn.fnamemodify(session_file, ':~'))
	vim.api.nvim_win_set_buf(winid, bufnr)
	vim.api.nvim_buf_delete(old_bufnr, {force = true})

    -- write the contents to buffer
    vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, output)
	vim.api.nvim_set_option_value('filetype', 'json', { buf = bufnr })
	vim.api.nvim_set_option_value('buftype', 'nofile', { buf = bufnr })
	vim.api.nvim_set_option_value('bufhidden', 'wipe', { buf = bufnr })
	vim.api.nvim_set_current_buf(bufnr)
	vim.api.nvim_set_option_value('modifiable', false, { buf = bufnr })

    -- set new keymap for current buffer
    vim.keymap.set('n', 'q', ':tabclose<CR>', { buffer = bufnr, noremap = true, silent = true })
end


return M
