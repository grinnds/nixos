local lint = require("lint")

lint.linters_by_ft = {
	python = { "mypy" },
	rust = { "clippy" },
	typescript = { "eslint_d" },
}

local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })

vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
	group = lint_augroup,
	callback = function()
		if vim.opt_local.modifiable:get() then
			lint.try_lint()
			lint.try_lint("codespell")
		end
	end,
})
