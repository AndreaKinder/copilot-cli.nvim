local M = {}

-- Default configuration
local default_config = {
	split_direction = "vertical", -- "vertical" or "horizontal"
}

local config = {}

local state = {
	bufnr = nil,
	winnr = nil,
	chan_id = nil,
}

local function close_copilot_window()
	if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
		vim.api.nvim_win_close(state.winnr, true)
	end
	state.winnr = nil
	state.bufnr = nil
	state.chan_id = nil
end

local function open_copilot_window()
	-- If the window is already open, just focus it.
	if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
		vim.api.nvim_set_current_win(state.winnr)
		return
	end

	-- Use configured split direction
	if config.split_direction == "horizontal" then
		vim.cmd("split")
	else
		vim.cmd("vsplit")
	end
	vim.cmd("enew")
	vim.cmd("setlocal buftype=nofile bufhidden=hide noswapfile")
	state.winnr = vim.api.nvim_get_current_win()
	state.bufnr = vim.api.nvim_get_current_buf()
	vim.api.nvim_buf_set_name(state.bufnr, "copilot_cli")

	state.chan_id = vim.fn.termopen("copilot", {
		env = { ["EDITOR"] = "nvim" },
		on_exit = function()
			-- Check if the window is still valid before trying to close it
			if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
				local buf_in_win = vim.api.nvim_win_get_buf(state.winnr)
				if buf_in_win == state.bufnr then
					vim.api.nvim_win_close(state.winnr, true)
				end
			end
			state.bufnr = nil
			state.winnr = nil
			state.chan_id = nil
		end,
	})
end

function M.toggle_copilot_cli()
	if state.winnr and vim.api.nvim_win_is_valid(state.winnr) then
		close_copilot_window()
	else
		open_copilot_window()
	end
end

local function show_floating_message(message)
	local width = #message + 4
	local height = 1

	local cursor_row, cursor_col = unpack(vim.api.nvim_win_get_cursor(0))

	local buf = vim.api.nvim_create_buf(false, true)
	vim.api.nvim_buf_set_lines(buf, 0, -1, false, { "  " .. message .. "  " })

	local win_config = {
		relative = "win",
		anchor = "NW",
		width = width,
		height = height,
		row = cursor_row - 1,
		col = cursor_col,
		focusable = false,
		style = "minimal",
		border = "rounded",
	}

	local win = vim.api.nvim_open_win(buf, false, win_config)

	vim.defer_fn(function()
		if vim.api.nvim_win_is_valid(win) then
			vim.api.nvim_win_close(win, true)
		end
	end, 3000)
end

function M.send_to_copilot()
	-- Check if the Copilot window is open and the channel is available.
	if not (state.winnr and vim.api.nvim_win_is_valid(state.winnr) and state.chan_id) then
		show_floating_message("Copilot CLI is not running. Please open it with <leader>oc first.")
		return
	end

	local _, start_line, start_col, _ = unpack(vim.fn.getpos("'<"))
	local _, end_line, end_col, _ = unpack(vim.fn.getpos("'>"))

	if start_line == 0 or end_line == 0 then
		show_floating_message("No text selected.")
		return
	end

	local lines = vim.api.nvim_buf_get_lines(0, start_line - 1, end_line, false)
	if #lines == 0 then
		show_floating_message("No text selected.")
		return
	end

	-- Handle visual selection precisely
	if #lines == 1 then
		lines[1] = string.sub(lines[1], start_col, end_col)
	else
		lines[#lines] = string.sub(lines[#lines], 1, end_col)
		lines[1] = string.sub(lines[1], start_col)
	end

	local text = table.concat(lines, "\n")

	if text and #text > 0 then
		vim.fn.chansend(state.chan_id, text .. "\n")
		vim.api.nvim_set_current_win(state.winnr)
	else
		show_floating_message("No text selected.")
	end
end

function M.setup(opts)
	-- Merge user config with defaults
	config = vim.tbl_deep_extend("force", default_config, opts or {})
	
	if vim.fn.executable("copilot-cli") == 1 then
		vim.api.nvim_set_keymap(
			"n",
			"<leader>oc",
			'<cmd>lua require("copilot").toggle_copilot_cli()<CR>',
			{ noremap = true, silent = true, desc = "Toggle Gemini CLI" }
		)
		vim.api.nvim_set_keymap(
			"v",
			"<leader>sg",
			':<C-U>lua require("copilot-cli").send_to_copilot()<CR>',
			{ noremap = true, silent = true, desc = "Send selection to Copilot" }
		)
	else
		local answer = vim.fn.input("Copilot CLI not found. Install it now? (y/n): ")
		if answer:lower() == "y" then
			local cmd = "npm install -g @github/copilot"
			vim.fn.termopen(cmd, {
				on_exit = function()
					vim.notify("Copilot CLI installation finished. Please restart Neovim to use the plugin.")
				end,
			})
		else
			vim.notify("Copilot CLI not found. The copilot.nvim plugin will not be loaded.", vim.log.levels.WARN)
		end
	end
end

return M
