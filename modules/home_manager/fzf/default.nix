{
  config,
  lib,
  ...
}:

{
  options = {
    ncfg.fzf.enable = lib.mkEnableOption "Enable fzf";
  };

  config = lib.mkIf config.ncfg.fzf.enable {
    programs.fzf = {
      enable = true;
    };
  };
}
