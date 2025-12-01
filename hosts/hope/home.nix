{
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.self.outputs.homeManagerModules.default
  ];

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
    throne
    telegram-desktop
    docker
    docker-compose
    wireshark
    bitwarden-desktop
    inputs.nix-alien.packages.${pkgs.stdenv.hostPlatform.system}.nix-alien

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

  stylix.targets = {
    waybar.enable = false;
    rofi.enable = false;
    hyprland.enable = false;
    hyprlock.enable = false;
    neovim.enable = false;
  };

  ncfg.fzf.enable = true;
  ncfg.hyprland = {
    enable = true;
    monitors = [ "eDP-1, 1920x1080@240, 0x0, 1.25" ];
  };
  ncfg.lsd.enable = true;
  ncfg.nvim.enable = true;
  ncfg.rofi.enable = true;
  ncfg.sesh.enable = true;
  ncfg.tmux.enable = true;
  ncfg.wallpaper.enable = true;
  ncfg.wezterm.enable = true;
  ncfg.yazi.enable = true;
  ncfg.zoxide.enable = true;
  ncfg.zsh.enable = true;

  # TODO: Check https://github.com/jesseduffield/lazygit/releases/tag/v0.50.0
  # autoForwardBranches
  programs.lazygit.enable = true;

  programs.bat.enable = true;

  programs.git = {
    enable = true;
    settings = {
      aliases = {
        ci = "commit";
        co = "checkout";
        s = "status";
      };
      user.name = "grinnds";
      user.email = "40234162+grinnds@users.noreply.github.com";
      push.autoSetupRemote = true;
      init.defaultBranch = "main";
    };
  };

  programs.gh = {
    enable = true;
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
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
  home.sessionVariables = { };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
