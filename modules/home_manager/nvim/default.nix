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
          svelte-language-server
          tailwindcss-language-server
          inotify-tools # better file watching

          # formatters
          stylua
          nixfmt
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
          postgresql_18
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
            type = "lua";
            config = ''
              vim.g.mapleader = ' ' 
              vim.g.maplocalleader = ' ' 

              vim.g.have_nerd_font = true
            '';
          }

          # theming
          {
            plugin = catppuccin-nvim;
            type = "lua";
            config = builtins.readFile ./config/plugin/catppuccin.lua;
          }

          # quality of life
          {
            plugin = mini-nvim;
            type = "lua";
            config = builtins.readFile ./config/plugin/mini.lua;
          }
          vim-sleuth
          {
            plugin = gitsigns-nvim;
            type = "lua";
            config = builtins.readFile ./config/plugin/gitsigns.lua;
          }
          {
            plugin = vim-tmux-navigator;
            type = "lua";
            config = builtins.readFile ./config/plugin/tmux.lua;
          }
          {
            plugin = render-markdown-nvim;
            type = "lua";
            config = "require('render-markdown').setup({})";
          }

          # file management
          {
            plugin = oil-nvim;
            type = "lua";
            config = builtins.readFile ./config/plugin/oil.lua;
          }

          plenary-nvim
          nvim-web-devicons
          telescope-fzf-native-nvim
          {
            plugin = telescope-nvim;
            type = "lua";
            config = builtins.readFile ./config/plugin/telescope.lua;
          }

          # debug
          {
            plugin = nvim-dap;
            type = "lua";
            config = builtins.readFile ./config/plugin/debug.lua;
          }
          nvim-dap-ui
          nvim-nio
          nvim-dap-go
          {
            plugin = nvim-dap-python;
            type = "lua";
            config = ''require("dap-python").setup("${python}/bin/python")'';
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
                p.tree-sitter-python
                p.tree-sitter-rust

                p.tree-sitter-make
                p.tree-sitter-markdown
                p.tree-sitter-markdown-inline
                p.tree-sitter-sql

                p.tree-sitter-json
                p.tree-sitter-toml

                p.tree-sitter-typescript
                p.tree-sitter-javascript
                p.tree-sitter-css
                p.tree-sitter-svelte
              ])
            );
            type = "lua";
            config = builtins.readFile ./config/plugin/treesitter.lua;
          }
          {
            plugin = nvim-treesitter-context;
            type = "lua";
            config = ''require("treesitter-context").setup({multiline_threshold=1})'';
          }
          lazydev-nvim
          {
            plugin = nvim-lspconfig;
            type = "lua";
            config = builtins.readFile ./config/plugin/lsp.lua;
          }
          {
            plugin = conform-nvim;
            type = "lua";
            config = builtins.readFile ./config/plugin/conform.lua;
          }
          {
            plugin = nvim-lint;
            type = "lua";
            config = builtins.readFile ./config/plugin/lint.lua;
          }
          {
            plugin = blink-cmp;
            type = "lua";
            config = builtins.readFile ./config/plugin/cmp.lua;
          }
          vim-dadbod
          vim-dadbod-completion
          blink-emoji-nvim
        ];

        initLua = "${builtins.readFile ./config/options.lua}";
      };
  };
}
