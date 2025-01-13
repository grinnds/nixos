require("oil").setup({
	delete_to_trash = true,
	view_options = {
		show_hidden = true,
	},
	lsp_file_methods = {
		autosave_changes = true,
	},
})

vim.keymap.set("n", "-", "<cmd>Oil<CR>")
