local init = require('last-session')

local M = {}

local config = init.config

-- check dir is existed and make it if not
M.check_dir = function(dir)
	if vim.fn.isdirectory(dir) == 0 then
		vim.fn.mkdir(dir, 'p')
	end
end

-- Function to check whether a file is to be ignored
M.filter_ignored = function(bufnr)
	local file_path = vim.api.nvim_buf_get_name(bufnr) -- get absolute path
	local file_type = vim.api.nvim_get_option_value('filetype', { buf = bufnr }) -- get filetype

	if not config then return nil end

	-- if ext of file is included in ignored_type
	local ext = file_path:match('%.([^%.]+)$')
	if ext and vim.tbl_contains(config.ignored_type, ext) then
		return nil
	end

	-- if filetype of file is included in ignored_type
	if file_type and vim.tbl_contains(config.ignored_type, file_type) then
		return nil
	end

	-- Check directory pattern
	for _, dir in ipairs(config.ignored_dir) do
		if file_path:find(dir, 1, true) then
			return nil
		end
	end

	return file_path
end

return M
