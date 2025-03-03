{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.ncfg.stylix;
in
{
  imports = [
    inputs.stylix.nixosModules.stylix
  ];

  options = {
    ncfg.stylix.enable = lib.mkEnableOption "Enable stylix";
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        useEmbeddedBitmaps = true;

        localConf = ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
          <fontconfig>
            <!-- Add Symbols Nerd Font as a global fallback -->
            <match target="pattern">
              <test name="family" compare="not_eq">
                <string>Symbols Nerd Font</string>
              </test>
              <edit name="family" mode="append">
                <string>Symbols Nerd Font</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
    };

    stylix = {
      enable = true;

      image = ./wallpappers/hololive.jpg;
      base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";
      polarity = "dark";

      opacity = {
        applications = 0.95;
        terminal = 0.80;
      };

      cursor = {
        name = "Bibata-Modern-Classic";
        package = pkgs.bibata-cursors;
        size = 24;
      };

      fonts = {
        sizes = {
          terminal = 14;
          applications = 12;
          popups = 12;
        };

        serif = {
          name = "Source Serif";
          package = pkgs.source-serif;
        };

        sansSerif = {
          name = "Noto Sans";
          package = pkgs.noto-fonts;
        };

        monospace = {
          name = "Jetbrains Mono";
          package = pkgs.nerd-fonts.jetbrains-mono;
        };

        emoji = {
          name = "Noto Color Emoji";
          package = pkgs.noto-fonts-emoji;
        };
      };
    };
  };
}
