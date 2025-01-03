{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options = {
    ncfg.nvim.enable = lib.mkEnableOption "Enable nvim";
  };

  config = lib.mkIf config.ncfg.nvim.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
    };

    programs.neovim =
      let
        toLua = str: "lua << EOF\n${str}\nEOF\n";
        toLuaFile = file: "lua << EOF\n${builtins.readFile file}\nEOF\n";
      in
      {
        package = inputs.neovim-nightly-overlay.packages.${pkgs.system}.default;

        enable = true;

        viAlias = true;
        vimAlias = true;
        vimdiffAlias = true;

        extraPackages = with pkgs; [
          xclip
          wl-clipboard

          ripgrep
          fd

          # lsp
          nixd
          lua-language-server
          gopls

          # formatters
          stylua
          nixfmt-rfc-style

          # tools
          gcc
          go
        ];

        plugins = with pkgs.vimPlugins; [
          # vimPlugins config is placed before extra config
          # leader key is required before any plugin is initialized
          # thus creating empty plugin with config setting leader key
          # this plugin should be at the top
          # https://github.com/nix-community/home-manager/issues/4609
          {
            plugin = pkgs.stdenv.mkDerivation {
              name = "empty";
              src = ./config/empty;
              installPhase = "cp -r $src $out";
              dontUnpack = true;
            };
            config = toLua ''vim.g.mapleader = ' ' vim.g.maplocalleader = ' ' '';
          }

          # theming
          {
            plugin = catppuccin-nvim;
            config = toLuaFile ./config/plugin/catppuccin.lua;
          }

          # quality of life
          {
            plugin = mini-nvim;
            config = toLuaFile ./config/plugin/mini.lua;
          }
          vim-sleuth
          {
            plugin = gitsigns-nvim;
            config = toLuaFile ./config/plugin/gitsigns.lua;
          }
          {
            plugin = vim-tmux-navigator;
            config = toLuaFile ./config/plugin/tmux.lua;
          }

          # file management
          {
            plugin = oil-nvim;
            config = toLuaFile ./config/plugin/oil.lua;
          }

          plenary-nvim
          nvim-web-devicons
          telescope-fzf-native-nvim
          {
            plugin = telescope-nvim;
            config = toLuaFile ./config/plugin/telescope.lua;
          }

          # code quality
          {
            plugin = (
              nvim-treesitter.withPlugins (p: [
                p.tree-sitter-nix
                p.tree-sitter-vim
                p.tree-sitter-vimdoc
                p.tree-sitter-lua
                p.tree-sitter-go
              ])
            );
            config = toLuaFile ./config/plugin/treesitter.lua;
          }
          lazydev-nvim
          {
            plugin = nvim-lspconfig;
            config = toLuaFile ./config/plugin/lsp.lua;
          }
          {
            plugin = conform-nvim;
            config = toLuaFile ./config/plugin/conform.lua;
          }
          {
            plugin = blink-cmp;
            config = toLuaFile ./config/plugin/cmp.lua;
          }
        ];

        extraLuaConfig = ''${builtins.readFile ./config/options.lua}'';
      };
  };
}
