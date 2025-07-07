local config = require('last-session.config')

local M = {}


-- check dir is existed and make it if not
M.check_dir = function(dir)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, 'p')
	end
end

-- Function to check whether a file is to be ignored
M.filter_ignored = function(bufnr)
	local options = config.get_config()
	local file_path = vim.api.nvim_buf_get_name(bufnr) -- get absolute path
	local file_type = vim.api.nvim_get_option_value('filetype', { buf = bufnr }) -- get filetype

	if not options then return nil end

	-- Remove unloaded / unlisted buffer
	if not (vim.api.nvim_buf_is_loaded(bufnr) or vim.api.nvim_get_option_value('buflisted', {buf = bufnr})) then -- check the buffer is opened
		return ""
	end

	-- Remove empty file path
	if #file_path < 1 then
		return "" -- no name file cannot be deleted, it must be ignored
	end

	-- if ext of file is included in ignored_type
	local ext = file_path:match('%.([^%.]+)$')
	if ext and vim.tbl_contains(options.ignored_list.ignored_type, ext) then
		return nil
	end

	-- if filetype of file is included in ignored_type
	if file_type and vim.tbl_contains(options.ignored_list.ignored_type, file_type) then
		return nil
	end

	-- Check directory pattern
	for _, dir in ipairs(options.ignored_list.ignored_dir) do
		if file_path:find(dir, 1, true) then
			return nil
		end
	end

	return file_path
end

---@param bufnr number target buffer to get bufindex
---@param buffers table session_data.buffers
---@return number|nil order index in session_data.buffers who matches with bufnr
M.get_bufidx = function (bufnr, buffers)
	for i, buffer in ipairs(buffers) do
		if buffer.bufnr == bufnr then
			return i
		end
	end
	return nil
end

return M
