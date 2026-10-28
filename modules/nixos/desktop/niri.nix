{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:
let
  cfg = config.ncfg.desktop.niri;
in
{
  options = {
    ncfg.desktop.niri.enable = lib.mkEnableOption "Enable niri";
  };

  config = lib.mkIf cfg.enable {
    services.upower.enable = true;

    services.displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
      };
    };

    programs.niri =
      let
        noctalia = inputs.wrapper-modules.lib.evalPackage [
          { inherit pkgs; }
          (
            {
              config,
              pkgs,
              lib,
              wlib,
              ...
            }:
            {
              imports = [ wlib.modules.default ];
              package = pkgs.noctalia;
              env = {
                NOCTALIA_CONFIG_HOME = lib.dirOf (lib.dirOf config.constructFiles.userConfig.path);
              };
              constructFiles.userConfig = {
                relPath = "${config.binName}/noctalia/config.toml";
                content = builtins.readFile ./noctalia.toml;
              };
            }
          )
        ];
        noctalia-cmd =
          cmd:
          [
            (lib.getExe noctalia)
            "msg"
          ]
          ++ cmd;
      in
      {
        enable = true;
        package = inputs.wrapper-modules.wrappers.niri.wrap {
          inherit pkgs;
          settings = {
            spawn-at-startup = [
              (lib.getExe noctalia)
            ];

            xwayland-satellite.path = lib.getExe pkgs.xwayland-satellite;

            input = {
              keyboard = {
                xkb = {
                  layout = "us,ru";
                  options = "grp:win_space_toggle,caps:ctrl_modifier";
                };
                repeat-delay = 300;
              };
              touchpad = {
                natural-scroll = _: { };
                dwt = _: { };
                scroll-factor = 0.8;
              };
              focus-follows-mouse = _: { };
            };

            binds = {
              "Print".spawn = noctalia-cmd [
                "screenshot-region"
              ];

              "Mod+Backspace".spawn = noctalia-cmd [
                "session"
                "lock"
              ];

              "Mod+Return" = _: {
                props = [
                  { repeat = false; }
                ];
                content = {
                  spawn-sh = lib.getExe pkgs.wezterm;
                };
              };
              "Mod+Shift+Return".spawn = noctalia-cmd [
                "panel-toggle"
                "launcher"
              ];
              "Mod+O" = _: {
                props = [
                  { repeat = false; }
                ];
                content = {
                  toggle-overview = _: { };
                };
              };
              "Mod+W" = _: {
                props = [
                  { repeat = false; }
                ];
                content = {
                  spawn-sh = "vivaldi";
                };
              };
              "Mod+Q" = _: {
                props = [
                  { repeat = false; }
                ];
                content = {
                  close-window = _: { };
                };
              };
              "Mod+F".maximize-column = _: { };
              "Mod+Shift+F".maximize-window-to-edges = _: { };

              "Mod+H".focus-column-left = _: { };
              "Mod+L".focus-column-right = _: { };
              "Mod+Left".focus-column-left = _: { };
              "Mod+Right".focus-column-right = _: { };

              "Mod+Shift+H".move-column-left = _: { };
              "Mod+Shift+L".move-column-right = _: { };
              "Mod+Shift+Left".move-column-left = _: { };
              "Mod+Shift+Right".move-column-right = _: { };

              "Mod+1".focus-workspace = "w0";
              "Mod+2".focus-workspace = "w1";
              "Mod+3".focus-workspace = "w2";
              "Mod+4".focus-workspace = "w3";
              "Mod+5".focus-workspace = "w4";
              "Mod+6".focus-workspace = "w5";

              "Mod+Shift+1".move-window-to-workspace = "w0";
              "Mod+Shift+2".move-window-to-workspace = "w1";
              "Mod+Shift+3".move-window-to-workspace = "w2";
              "Mod+Shift+4".move-window-to-workspace = "w3";
              "Mod+Shift+5".move-window-to-workspace = "w4";
              "Mod+Shift+6".move-window-to-workspace = "w5";
            };

            layout = {
              gaps = 6;
            };

            workspaces = {
              "w0" = { };
              "w1" = { };
              "w2" = { };
              "w3" = { };
              "w4" = { };
              "w5" = { };
            };

            window-rules = [
              {
                match = _: {
                  props = {
                    app-id = "vivaldi";
                  };
                };
                open-on-workspace = "w1";
                open-maximized-to-edges = true;
              }
              {
                match = _: {
                  props = {
                    app-id = "org.telegram.desktop";
                  };
                };
                open-on-workspace = "w2";
                open-maximized-to-edges = true;
              }
            ];

            gestures = {
              hot-corners.off = _: { };
            };
          };

          env = {
            QT_QPA_PLATFORM = "wayland";
            _JAVA_AWT_WM_NONREPARENTING = "1";
          };
        };
      };
  };
}
