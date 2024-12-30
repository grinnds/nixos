{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    ncfg.tmux.enable = lib.mkEnableOption "Enable tmux";
  };

  config = lib.mkIf config.ncfg.tmux.enable {
    # required for tmux-yank
    home.packages = with pkgs; [
      wl-clipboard
    ];

    programs.tmux = {
      enable = true;

      shortcut = "a";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      keyMode = "vi";

      sensibleOnTop = true;
      plugins = with pkgs.tmuxPlugins; [
        # TODO: Probably not working
        resurrect
        continuum
        yank
        catppuccin
      ];

      # TODO: Move to config file
      extraConfig = ''
        set -g renumber-windows on
        set -g set-clipboard on

        set -g @catppuccin_flavor "mocha"
      '';
    };
  };
}
