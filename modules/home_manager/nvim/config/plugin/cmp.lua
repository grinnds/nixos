local trigger_text = ";"

require("blink.cmp").setup({
	keymap = { preset = "default" },

	-- I noticed that telescope was extremely slow and taking too long to open,
	-- assumed related to blink, so disabled blink and in fact it was related
	-- :lua print(vim.bo[0].filetype)
	-- So I'm disabling blink.cmp for Telescope
	enabled = function()
		-- Get the current buffer's filetype
		local filetype = vim.bo[0].filetype
		-- Disable for Telescope buffers
		if filetype == "TelescopePrompt" or filetype == "minifiles" then
			return false
		end
		return true
	end,

	snippets = {
		preset = "luasnip",
		expand = function(snippet)
			require("luasnip").lsp_expand(snippet)
		end,
		active = function(filter)
			if filter and filter.direction then
				return require("luasnip").jumpable(filter.direction)
			end
			return require("luasnip").in_snippet()
		end,
		jump = function(direction)
			require("luasnip").jump(direction)
		end,
	},

	sources = {
		default = { "lsp", "path", "snippets", "buffer", "lazydev", "emoji", "markdown" },
		providers = {
			lsp = {
				name = "LSP",
				module = "blink.cmp.sources.lsp",
				enabled = true,
				score_offset = 100,
			},
			path = {
				name = "Path",
				module = "blink.cmp.sources.path",
				enabled = true,
				score_offset = 25,
				opts = {
					trailing_slash = false,
					label_trailing_slash = true,
					show_hidden_files_by_default = true,
				},
			},
			snippets = {
				name = "Snippets",
				module = "blink.cmp.sources.snippets",
				enabled = true,
				score_offset = 85,
				max_items = 8,
				min_keyword_length = 2,
				should_show_items = function()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local before_cursor = vim.api.nvim_get_current_line():sub(1, col)
					-- NOTE: remember that `trigger_text` is modified at the top of the file
					return before_cursor:match(trigger_text .. "%w*$") ~= nil
				end,
				-- After accepting the completion, delete the trigger_text characters
				-- from the final inserted text
				transform_items = function(_, items)
					local line = vim.api.nvim_get_current_line()
					local col = vim.api.nvim_win_get_cursor(0)[2]
					local before_cursor = line:sub(1, col)
					local start_pos, end_pos = before_cursor:find(trigger_text .. "[^" .. trigger_text .. "]*$")
					if start_pos and end_pos then
						for _, item in ipairs(items) do
							if not item.trigger_text_modified then
								---@diagnostic disable-next-line: inject-field
								item.trigger_text_modified = true
								item.textEdit = {
									newText = item.insertText or item.label,
									range = {
										start = { line = vim.fn.line(".") - 1, character = start_pos - 1 },
										["end"] = { line = vim.fn.line(".") - 1, character = end_pos },
									},
								}
							end
						end
					end
					return items
				end,
			},
			buffer = {
				name = "Buffer",
				enabled = true,
				max_items = 5,
				module = "blink.cmp.sources.buffer",
				score_offset = 14,
			},
			lazydev = {
				name = "LazyDev",
				module = "lazydev.integrations.blink",
				enabled = true,
				score_offset = 105,
			},
			emoji = {
				module = "blink-emoji",
				name = "Emoji",
				score_offset = 15,
				max_items = 5,
				min_keyword_length = 2,
			},
			markdown = {
				name = "RenderMarkdown",
				module = "render-markdown.integ.blink",
				fallbacks = { "lsp" },
			},
		},
	},

	cmdline = {
		completion = {
			keymap = { preset = "inherit" },
			menu = {
				auto_show = true,
			},
		},
	},

	appearance = {
		use_nvim_cmp_as_default = true,
		nerd_font_variant = "mono",
	},

	completion = {
		menu = {
			border = "single",
			draw = {
				treesitter = { "lsp" },
				columns = {
					{ "label", "label_description", gap = 1 },
					{ "kind_icon", "kind", gap = 1 },
					{ "source_name" },
				},
			},
		},
		documentation = {
			auto_show = true,
			window = {
				border = "single",
			},
		},
		accept = {
			auto_brackets = {
				enabled = false,
			},
		},
		-- don't use
		ghost_text = { enabled = false },
	},

	-- use Ctrl+S
	-- signature = { enabled = true },
})
