local capabilites = require("blink.cmp").get_lsp_capabilities()
local lspconfig = require("lspconfig")

lspconfig.nixd.setup({
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

lspconfig.gopls.setup({})
