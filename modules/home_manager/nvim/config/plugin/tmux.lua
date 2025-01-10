vim.g.tmux_navigator_preserve_zoom = 1
vim.g.tmux_navigator_no_wrap = 1

vim.keymap.set("n", "<c-h>", "<cmd><C-U>TmuxNavigateLeft<CR>")
vim.keymap.set("n", "<c-j>", "<cmd><C-U>TmuxNavigateDown<CR>")
vim.keymap.set("n", "<c-k>", "<cmd><C-U>TmuxNavigateUp<CR>")
vim.keymap.set("n", "<c-l>", "<cmd><C-U>TmuxNavigateRight<CR>")
