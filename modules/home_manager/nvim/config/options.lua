vim.opt.number = true
vim.opt.relativenumber = true

vim.opt.showmode = false

vim.opt.clipboard = "unnamedplus"
vim.opt.tabstop = 4
vim.opt.shiftwidth = 4

vim.opt.mouse = "a"
vim.opt.splitright = true
vim.opt.splitbelow = true

vim.opt.updatetime = 250
-- TODO: add whichkey or don't use this
-- vim.opt.timeoutlen = 300

vim.keymap.set("n", "<esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("t", "<Esc><Esc>", "<C-\\><C-n>", { desc = "Exit terminal mode" })

vim.keymap.set("n", "<c-h>", "<c-w><c-h>", { desc = "Move focus to the left window" })
vim.keymap.set("n", "<c-l>", "<c-w><c-l>", { desc = "Move focus to the right window" })
vim.keymap.set("n", "<c-j>", "<c-w><c-j>", { desc = "Move focus to the lower window" })
vim.keymap.set("n", "<c-k>", "<c-w><c-k>", { desc = "Move focus to the upper window" })

vim.api.nvim_create_autocmd("TextYankPost", {
	desc = "Highlight when yanking (copying) text",
	group = vim.api.nvim_create_augroup("kickstart-highlight-yank", { clear = true }),
	callback = function()
		vim.highlight.on_yank()
	end,
})

vim.api.nvim_create_autocmd("FileType", {
	pattern = "markdown",
	callback = function()
		vim.opt_local.wrap = false
	end,
})
