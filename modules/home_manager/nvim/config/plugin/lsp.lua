local lspconfig = require("lspconfig")

local on_attach = function(client, bufnr)
	local map = function(keys, func, desc, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, func, { buffer = bufnr, desc = "LSP: " .. desc })
	end

	local unmap = function(keys, mode)
		mode = mode or "n"
		vim.keymap.set(mode, keys, "<nop>")
	end

	map("gd", require("telescope.builtin").lsp_definitions, "[G]oto [D]efinition")
	map("gr", require("telescope.builtin").lsp_references, "[G]oto [R]eferences")
	unmap("grr")
	map("gI", require("telescope.builtin").lsp_implementations, "[G]oto [I]mplementation")
	map("<leader>D", require("telescope.builtin").lsp_type_definitions, "Type [D]efinition")
	map("<leader>ds", require("telescope.builtin").lsp_document_symbols, "[D]ocument [S]ymbols")
	map("<leader>ws", require("telescope.builtin").lsp_dynamic_workspace_symbols, "[W]orkspace [S]ymbols")
	map("<leader>rn", vim.lsp.buf.rename, "[R]e[n]ame")
	unmap("grn")
	map("<leader>ca", vim.lsp.buf.code_action, "[C]ode [A]ction", { "n", "x" })
	unmap("gra")
	map("gD", vim.lsp.buf.declaration, "[G]oto [D]eclaration")
	map("K", vim.lsp.buf.hover, "Show LSP Hover")

	if client and client.supports_method(vim.lsp.protocol.Methods.textDocument_documentHighlight) then
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

if vim.g.have_nerd_font then
	local signs = { ERROR = "", WARN = "", INFO = "", HINT = "" }
	local diagnostic_signs = {}
	for type, icon in pairs(signs) do
		diagnostic_signs[vim.diagnostic.severity[type]] = icon
	end
	vim.diagnostic.config({ signs = { text = diagnostic_signs } })
end

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
