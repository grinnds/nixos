{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  options = {
    ncfg.tmux.enable = lib.mkEnableOption "Enable tmux";
  };

  config = lib.mkIf config.ncfg.tmux.enable {
    programs.tmux = {
      enable = true;

      shortcut = "a";
      baseIndex = 1;
      newSession = true;
      escapeTime = 0;
      keyMode = "vi";

      sensibleOnTop = true;
      plugins = with pkgs.tmuxPlugins; [
        tokyo-night-tmux
        yank
      ];
    };
  };
}
