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
        noctalia = inputs.wrapper-modules.wrappers.noctalia-shell.wrap {
          inherit pkgs;
          settings = (builtins.fromJSON (builtins.readFile ./noctalia.json)).settings;
        };
        noctalia-cmd =
          cmd:
          [
            (lib.getExe noctalia)
            "ipc"
            "call"
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
              "Print".screenshot-screen = _: {
                props = {
                  write-to-disk = false;
                };
              };

              "Mod+Backspace".spawn = noctalia-cmd [
                "lockScreen"
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
                "launcher"
                "toggle"
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

              "Mod+H".focus-column-left = _: { };
              "Mod+L".focus-column-right = _: { };
              "Mod+Left".focus-column-left = _: { };
              "Mod+Right".focus-column-right = _: { };

              "Mod+Shift+H".move-column-left = _: { };
              "Mod+Shift+L".move-column-right = _: { };
              "Mod+Shift+Left".move-column-left = _: { };
              "Mod+Shift+Right".move-column-right = _: { };

              "Mod+1".focus-workspace = 1;
              "Mod+2".focus-workspace = 2;
              "Mod+3".focus-workspace = 3;
              "Mod+4".focus-workspace = 4;
              "Mod+5".focus-workspace = 5;
              "Mod+6".focus-workspace = 6;

              "Mod+Shift+1".move-window-to-workspace = 1;
              "Mod+Shift+2".move-window-to-workspace = 2;
              "Mod+Shift+3".move-window-to-workspace = 3;
              "Mod+Shift+4".move-window-to-workspace = 4;
              "Mod+Shift+5".move-window-to-workspace = 5;
              "Mod+Shift+6".move-window-to-workspace = 6;
            };

            layout = {
              gaps = 6;
            };
          };

          env = {
            QT_QPA_PLATFORM = "wayland";
          };
        };
      };
  };
}
