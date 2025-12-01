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
        python = pkgs.python313.withPackages (p: [
          p.debugpy
        ]);
      in
      {
        package = inputs.neovim-nightly-overlay.packages.${pkgs.stdenv.hostPlatform.system}.default;

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
          marksman
          basedpyright
          vscode-langservers-extracted # jsonls
          rust-analyzer
          typescript-language-server
          inotify-tools # better file watching

          # formatters
          stylua
          nixfmt-rfc-style
          gotools
          golines
          nodePackages.prettier
          jq
          taplo
          codespell
          rustfmt

          # linters
          ruff
          mypy
          clippy
          eslint_d

          # debuggers
          delve
          python

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
            config = toLua ''
              vim.g.mapleader = ' ' 
              vim.g.maplocalleader = ' ' 

              vim.g.have_nerd_font = true
            '';
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
          {
            plugin = render-markdown-nvim;
            config = toLua "require('render-markdown').setup({})";
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

          # ai
          {
            plugin = avante-nvim;
            config = toLuaFile ./config/plugin/avante.lua;
          }
          nui-nvim

          # debug
          {
            plugin = nvim-dap;
            config = toLuaFile ./config/plugin/debug.lua;
          }
          nvim-dap-ui
          nvim-nio
          nvim-dap-go
          {
            plugin = nvim-dap-python;
            config = toLua ''require("dap-python").setup("${python}/bin/python")'';
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
                p.tree-sitter-markdown
                p.tree-sitter-markdown-inline
                p.tree-sitter-python
                p.tree-sitter-json
                p.tree-sitter-toml
                p.tree-sitter-rust
                p.tree-sitter-typescript
              ])
            );
            config = toLuaFile ./config/plugin/treesitter.lua;
          }
          {
            plugin = nvim-treesitter-context;
            config = toLua ''require("treesitter-context").setup({multiline_threshold=1})'';
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
            plugin = nvim-lint;
            config = toLuaFile ./config/plugin/lint.lua;
          }
          {
            plugin = blink-cmp;
            config = toLuaFile ./config/plugin/cmp.lua;
          }
          {
            plugin = luasnip;
            config = toLuaFile ./config/plugin/luasnip.lua;
          }
          blink-emoji-nvim
        ];

        extraLuaConfig = ''${builtins.readFile ./config/options.lua}'';
      };
  };
}
