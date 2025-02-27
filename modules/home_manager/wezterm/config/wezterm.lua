local M = {}

local wezterm = require("wezterm")

-- https://github.com/wez/wezterm/issues/6079
-- getting rectangles instead of text
-- M.enable_wayland = false
-- M.front_end = "WebGpu"

M.window_decorations = "NONE"
M.enable_tab_bar = false
-- M.window_decorations = "RESIZE"
-- M.window_background_opacity = 0.85
M.audible_bell = "Disabled"
M.hide_tab_bar_if_only_one_tab = true

M.font = wezterm.font_with_fallback({
	"JetBrains Mono",
	"Fira Code",
	"Noto Color Emoji",
})
-- M.font = wezterm.font("JetBrains Mono")
M.font_size = 10
M.color_scheme = "Catppuccin Mocha"

return M
