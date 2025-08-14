require("avante_lib").load()
require("avante").setup({
	hints = { enabled = false },
	behaviour = {
		use_cwd_as_project_root = true,
	},
	provider = "openrouter",
	providers = {
		openrouter = {
			__inherited_from = "openai",
			endpoint = "https://openrouter.ai/api/v1",
			api_key_name = "OPENROUTER_API_KEY",
			model = "deepseek/deepseek-chat-v3-0324:free",
		},
	},
	-- openai = {
	--   model = "claude-3-7-sonnet-20250219",
	--   proxy = "socks://127.0.0.1:2080",
	-- },
})
