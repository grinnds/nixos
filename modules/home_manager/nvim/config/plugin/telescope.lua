local actions = require("telescope.actions")

require("telescope").setup({
	extensions = {
		fzf = {
			fuzzy = true,
			override_generic_sorter = true,
			override_file_sorter = true,
			case_mode = "smart_case",
		},
	},
	pickers = {
		buffers = {
			mappings = {
				n = {
					["<c-d>"] = actions.delete_buffer,
				},
				i = {
					["<c-d>"] = actions.delete_buffer,
				},
			},
		},
	},
})

require("telescope").load_extension("fzf")

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>ff", builtin.find_files)
vim.keymap.set("n", "<leader>fh", builtin.help_tags)
vim.keymap.set("n", "<leader>fb", builtin.buffers)
vim.keymap.set("n", "<leader>fs", builtin.live_grep)
vim.keymap.set("n", "<leader>fd", builtin.diagnostics)
vim.keymap.set("n", "<leader>ec", function()
	require("telescope.builtin").find_files({
		cwd = "/etc/nixos/",
	})
end)
