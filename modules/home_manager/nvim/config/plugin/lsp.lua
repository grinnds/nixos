local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	local unmap = function(keys, mode)
		mode = mode or "n"
		pcall(vim.keymap.del, mode, keys)
		-- Old code, testing new one
		-- vim.keymap.set(mode, keys, "<nop>")
	end

	map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	unmap("grr")
	map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	unmap("gri")
	map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	unmap("grn")
	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
	unmap("gra")
	map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	map("K", vim.lsp.buf.hover, "Show LSP Hover")

	if client and client:supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight, bufnr) then
		local highlight_augroup = vim.api.nvim_create_augroup("kickstart-lsp-highlight", { clear = false })
		vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
			buffer = bufnr,
			group = highlight_augroup,
			callback = vim.lsp.buf.document_highlight,
		})

		vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
			buffer = bufnr,
			group = highlight_augroup,
			callback = vim.lsp.buf.clear_references,
		})

		vim.api.nvim_create_autocmd("LspDetach", {
			group = vim.api.nvim_create_augroup("kickstart-lsp-detach", { clear = true }),
			callback = function(event)
				vim.lsp.buf.clear_references()
				vim.api.nvim_clear_autocmds({ group = "kickstart-lsp-highlight", buffer = event.buf })
			end,
		})
	end
end

local capabilites = require("blink.cmp").get_lsp_capabilities()

vim.diagnostic.config({
	severity_sort = true,
	float = { border = "rounded", source = "if_many" },
	underline = { severity = vim.diagnostic.severity.ERROR },
	signs = vim.g.have_nerd_font and {
		text = {
			[vim.diagnostic.severity.ERROR] = "󰅚 ",
			[vim.diagnostic.severity.WARN] = "󰀪 ",
			[vim.diagnostic.severity.INFO] = "󰋽 ",
			[vim.diagnostic.severity.HINT] = "󰌶 ",
		},
	} or {},
	virtual_text = {
		source = "if_many",
		spacing = 2,
		format = function(diagnostic)
			local diagnostic_message = {
				[vim.diagnostic.severity.ERROR] = diagnostic.message,
				[vim.diagnostic.severity.WARN] = diagnostic.message,
				[vim.diagnostic.severity.INFO] = diagnostic.message,
				[vim.diagnostic.severity.HINT] = diagnostic.message,
			}
			return diagnostic_message[diagnostic.severity]
		end,
	},
})

lspconfig.nixd.setup({
	on_attach = on_attach,
	capabalities = capabilites,
	settings = {
		nixd = {
			nixpkgs = {
				expr = "import <nixpkgs> { }",
			},
			formatting = {
				command = { "nixfmt" },
			},
			-- TODO: make it work
			-- options = {
			-- 	nixos = {
			-- 		expr = '(builtins.getFlake ("/etc/nixos/")).nixosConfigurations.hope.options',
			-- 	},
			-- },
		},
	},
})

require("lazydev").setup({
	library = {
		{ path = "${3rd}/luv/library", words = { "vim%.uv" } },
	},
})
lspconfig.lua_ls.setup({
	on_attach = on_attach,
	capabalities = capabilites,
	settings = {
		Lua = {
			completion = {
				callSnippet = "Replace",
			},
			diagnostics = { disable = { "missing-fields" } },
		},
	},
})

lspconfig.gopls.setup({
	on_attach = on_attach,
	capabilites = capabilites,
	settings = {
		gopls = {
			completeUnimported = true,
			usePlaceholders = true,
			analyses = {
				unusedparams = true,
			},
		},
	},
})

lspconfig.marksman.setup({
	on_attach = on_attach,
	capabilites = capabilites,
})

lspconfig.pyright.setup({
	on_attach = on_attach,
	capabilites = capabilites,
})

lspconfig.ruff.setup({
	on_attach = on_attach,
	capabilites = capabilites,
})

lspconfig.jsonls.setup({
	on_attach = on_attach,
	capabilites = capabilites,
})

lspconfig.rust_analyzer.setup({
	on_attach = on_attach,
	capabilites = capabilites,
})
