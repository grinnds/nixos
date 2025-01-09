-- TODO: Testing with dsiable zoomed
-- check out "tmux_navigator_preserve_zoom" with "tmux_navigator_no_wrap"
vim.g.tmux_navigator_disable_when_zoomed = 1

vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<CR>")
