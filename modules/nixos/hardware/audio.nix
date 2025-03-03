{
  config,
  lib,
  ...
}:
let
  cfg = config.ncfg.hardware.audio;
in
{
  options = {
    ncfg.hardware.audio.enable = lib.mkEnableOption "Enable hardware audio support";
  };

  config = lib.mkIf cfg.enable {
    services.pulseaudio.enable = false;
    security.rtkit.enable = true;
    services.pipewire = {
      enable = true;
      alsa = {
        enable = true;
        support32Bit = true;
      };
      pulse.enable = true;
      jack.enable = true;
    };
  };
}
