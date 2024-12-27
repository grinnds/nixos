require("mini.ai").setup({ n_lines = 500 })

require("mini.surround").setup()

require("mini.pairs").setup()

require("mini.icons").setup()

local statusline = require("mini.statusline")
-- set use_icons to true if you have a Nerd Font
statusline.setup({ use_icons = vim.g.have_nerd_font })
