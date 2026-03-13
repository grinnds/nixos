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

	sources = {
		default = { "lsp", "path", "buffer", "dadbod", "lazydev", "emoji", "markdown" },
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
			buffer = {
				name = "Buffer",
				enabled = true,
				max_items = 5,
				module = "blink.cmp.sources.buffer",
				score_offset = 14,
			},
			-- Example on how to configure dadbod found in the main repo
			-- https://github.com/kristijanhusak/vim-dadbod-completion
			dadbod = {
				name = "Dadbod",
				module = "vim_dadbod_completion.blink",
				min_keyword_length = 2,
				score_offset = 85,
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
