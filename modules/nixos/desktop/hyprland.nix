{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.ncfg.desktop.hyprland;
in
{
  options = {
    ncfg.desktop.hyprland.enable = lib.mkEnableOption "Enable hyprland";
  };

  config = lib.mkIf cfg.enable {
    nix = {
      settings = {
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
    };

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
    };

    services.gnome.gnome-keyring.enable = true;
    security.polkit.enable = true;
    security.pam.services.swaylock = {
      text = ''
        auth include login
      '';
    };
    xdg = {
      autostart.enable = true;
      portal = {
        enable = true;
        extraPortals = with pkgs; [
          xdg-desktop-portal-hyprland
        ];
      };
    };
    environment.sessionVariables.NIXOS_OZONE_WL = "1";
  };
}
