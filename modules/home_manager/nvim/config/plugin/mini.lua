require("mini.ai").setup({ n_lines = 500 })

require("mini.surround").setup()

require("mini.pairs").setup()
vim.api.nvim_create_autocmd({ "FileType" }, {
	group = vim.api.nvim_create_augroup("custom_rust_disable_single_quote_pairs", { clear = true }),
	pattern = "rust",
	callback = function()
		vim.keymap.set("i", "'", "'", { buffer = 0 })
	end,
})

require("mini.icons").setup()

local statusline = require("mini.statusline")
-- set use_icons to true if you have a Nerd Font
statusline.setup({ use_icons = vim.g.have_nerd_font })
