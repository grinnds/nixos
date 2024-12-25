{
  config,
  pkgs,
  inputs,
  ...
}:

{
  home.username = "baris";
  home.homeDirectory = "/home/baris";
  home.keyboard = null;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "24.11";

  home.packages = with pkgs; [
    brave
    nekoray
    telegram-desktop
    docker
    docker-compose
    wireshark
    bitwarden-desktop

    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  qt = {
    enable = true;
    platformTheme.name = "kde";
    style.name = "breeze-dark";
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
  };

  programs.bat = {
    enable = true;
  };

  programs.git = {
    enable = true;
    aliases = {
      ci = "commit";
      co = "checkout";
      s = "status";
    };
    userName = "grinnds";
    userEmail = "grinnds@example.com";
    extraConfig = {
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
      credential.helper = "oauth";
    };
  };

  programs.gh = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    nix-direnv.enable = true;
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

        nixd
        nixfmt-rfc-style

        lua-language-server
        stylua
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
            src = ./nvim/empty;
            installPhase = "cp -r $src $out";
            dontUnpack = true;
          };
          config = toLua ''vim.g.mapleader = ' ' vim.g.maplocalleader = ' ' '';
        }

        # theming
        {
          plugin = tokyonight-nvim;
          config = "colorscheme tokyonight-night";
        }

        # quality of life
        {
          plugin = mini-nvim;
          config = toLuaFile ./nvim/plugin/mini.lua;
        }
        vim-sleuth

        # file management
        {
          plugin = oil-nvim;
          config = toLuaFile ./nvim/plugin/oil.lua;
        }

        plenary-nvim
        nvim-web-devicons
        telescope-fzf-native-nvim
        {
          plugin = telescope-nvim;
          config = toLuaFile ./nvim/plugin/telescope.lua;
        }

        # code quality
        {
          plugin = (
            nvim-treesitter.withPlugins (p: [
              p.tree-sitter-nix
              p.tree-sitter-vim
              p.tree-sitter-vimdoc
              p.tree-sitter-lua
            ])
          );
          config = toLuaFile ./nvim/plugin/treesitter.lua;
        }
        lazydev-nvim
        {
          plugin = nvim-lspconfig;
          config = toLuaFile ./nvim/plugin/lsp.lua;
        }
        {
          plugin = conform-nvim;
          config = toLuaFile ./nvim/plugin/conform.lua;
        }
        {
          plugin = blink-cmp;
          config = toLuaFile ./nvim/plugin/cmp.lua;
        }
      ];

      extraLuaConfig = ''${builtins.readFile ./nvim/options.lua}'';
    };

  programs.tmux = {
    enable = true;
  };

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/baris/etc/profile.d/hm-session-vars.sh
  #

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
