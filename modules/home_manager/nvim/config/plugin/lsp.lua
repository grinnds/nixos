local capabilites = require("blink.cmp").get_lsp_capabilities()

require("lspconfig").nixd.setup({
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
require("lspconfig").lua_ls.setup({
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
