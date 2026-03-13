{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ncfg.hyprland;
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;

      systemd.enable = true;
      systemd.enableXdgAutostart = true;
      xwayland.enable = true;

      settings = {
        "$modifier" = "SUPER";

        exec-once = [
          "dbus-update-activation-environment --systemd --all"
          "systemctl --user import-environment QT_QPA_PLATFORMTHEME"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "${pkgs.pyprland}/bin/pypr"
          "${pkgs.hyprpaper}/bin/hyprpaper"
          "${pkgs.networkmanagerapplet}/bin/nm-applet"
        ];

        input = {
          kb_layout = "us,ru";
          kb_options = "grp:win_space_toggle,caps:ctrl_modifier";
          repeat_delay = 300;
          follow_mouse = 1;
          sensitivity = 0;
          touchpad = {
            natural_scroll = true;
            disable_while_typing = true;
            scroll_factor = 0.8;
          };
        };

        general = {
          monitor = cfg.monitors;
          layout = "dwindle";
          gaps_in = 6;
          gaps_out = 8;
          border_size = 2;
          resize_on_border = true;
          "col.active_border" =
            "rgb(${config.lib.stylix.colors.base08}) rgb(${config.lib.stylix.colors.base0C}) 45deg";
          "col.inactive_border" = "rgb(${config.lib.stylix.colors.base01})";
        };

        misc = {
          layers_hog_keyboard_focus = true;
          initial_workspace_tracking = 0;
          force_default_wallpaper = 0;
          mouse_move_enables_dpms = true;
          key_press_enables_dpms = false;
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        decoration = {
          rounding = 10;
          blur = {
            enabled = true;
            size = 5;
            passes = 3;
            ignore_opacity = false;
            new_optimizations = true;
          };
          shadow = {
            enabled = true;
            range = 4;
            render_power = 3;
            color = "rgba(1a1a1aee)";
          };
        };

        animations = {
          enabled = true;
          bezier = [
            "wind, 0.05, 0.9, 0.1, 1.05"
            "winIn, 0.1, 1.1, 0.1, 1.1"
            "winOut, 0.3, -0.3, 0, 1"
            "liner, 1, 1, 1, 1"
          ];
          animation = [
            "windows, 1, 6, wind, slide"
            "windowsIn, 1, 6, winIn, slide"
            "windowsOut, 1, 5, winOut, slide"
            "windowsMove, 1, 5, wind, slide"
            "border, 1, 1, liner"
            "fade, 1, 10, default"
            "workspaces, 1, 5, wind"
          ];
        };

        windowrule = [
          "match:class ^([Tt]hunar|org.gnome.Nautilus|[Pp]cmanfm-qt)$, tag +file-manager"
          "match:class ^(wezterm)$, tag +terminal"
          "match:class ^(Brave-browser(-beta|-dev|-unstable)?)$, tag +browser"
          "match:class ^([Ff]irefox|org.mozilla.firefox|[Ff]irefox-esr)$, tag +browser"
          "match:class ^([Gg]oogle-chrome(-beta|-dev|-unstable)?)$, tag +browser"
          "match:class ^([Tt]horium-browser|[Cc]achy-browser)$, tag +browser"
          "match:class ^(codium|codium-url-handler|VSCodium)$, tag +projects"
          "match:class ^(VSCode|code-url-handler)$, tag +projects"
          "match:class ^([Dd]iscord|[Ww]ebCord|[Vv]esktop)$, tag +im"
          "match:class ^([Ff]erdium)$, tag +im"
          "match:class ^([Ww]hatsapp-for-linux)$, tag +im"
          "match:class ^(org.telegram.desktop|io.github.tdesktop_x64.TDesktop)$, tag +im"
          "match:class ^(teams-for-linux)$, tag +im"
          "match:class ^(gamescope)$, tag +games"
          "match:class ^(steam_app_\\d+)$, tag +games"
          "match:class ^([Ss]team)$, tag +gamestore"
          "match:title ^([Ll]utris)$, tag +gamestore"
          "match:class ^(com.heroicgameslauncher.hgl)$, tag +gamestore"
          "match:class ^(gnome-disks|wihotspot(-gui)?)$, tag +settings"
          "match:class ^([Rr]ofi)$, tag +settings"
          "match:class ^(file-roller|org.gnome.FileRoller)$, tag +settings"
          "match:class ^(nm-applet|nm-connection-editor|blueman-manager)$, tag +settings"
          "match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$, tag +settings"
          "match:class ^(nwg-look|qt5ct|qt6ct|[Yy]ad)$, tag +settings"
          "match:class (xdg-desktop-portal-gtk), tag +settings"

          "match:title ^(Picture-in-Picture)$, move 72% 7%"
          "match:class ^([Ff]erdium)$, center on"
          "match:class ^(pavucontrol|org.pulseaudio.pavucontrol|com.saivert.pwvucontrol)$, center on"
          "match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*), center on"
          "match:title ^(Authentication Required)$, center on"

          "match:fullscreen true, idle_inhibit fullscreen"

          "match:tag settings.*, float on"
          "match:class ^([Ff]erdium)$, float on"
          "match:title ^(Picture-in-Picture)$, float on"
          "match:class ^(mpv|com.github.rafostar.Clapper)$, float on"
          "match:title ^(Authentication Required)$, float on"
          "match:class (codium|codium-url-handler|VSCodium), match:title negative:(.*codium.*|.*VSCodium.*), float on"
          "match:class ^(com.heroicgameslauncher.hgl)$, match:title negative:(Heroic Games Launcher), float on"
          "match:class ^([Ss]team)$, match:title negative:^([Ss]team)$, float on"
          "match:class ([Tt]hunar), match:title negative:(.*[Tt]hunar.*), float on"
          "match:initial_title (Add Folder to Workspace), float on"
          "match:initial_title (Open Files), float on"
          "match:initial_title (wants to save), float on"

          "match:initial_title (Open Files), size 70% 60%"
          "match:initial_title (Add Folder to Workspace), size 70% 60%"
          "match:tag settings.*, size 70% 70%"
          "match:class ^([Ff]erdium)$, size 60% 70%"

          "match:tag browser.*, opacity 1.0 1.0"
          "match:tag projects.*, opacity 0.9 0.8"
          "match:tag im.*, opacity 0.94 0.86"
          "match:tag file-manager.*, opacity 0.9 0.8"
          "match:tag terminal.*, opacity 0.8 0.7"
          "match:tag settings.*, opacity 0.8 0.7"
          "match:class ^(gedit|org.gnome.TextEditor|mousepad)$, opacity 0.8 0.7"
          "match:class ^(seahorse)$, opacity 0.9 0.8"
          "match:title ^(Picture-in-Picture)$, opacity 0.95 0.75"

          "match:title ^(Picture-in-Picture)$, pin on"
          "match:title ^(Picture-in-Picture)$, keep_aspect_ratio on"

          "match:tag games.*, no_blur on"
          "match:tag games.*, fullscreen on"
        ];

        env = [
          "NIXOS_OZONE_WL, 1"
          "NIXPKGS_ALLOW_UNFREE, 1"
          "XDG_CURRENT_DESKTOP, Hyprland"
          "XDG_SESSION_TYPE, wayland"
          "XDG_SESSION_DESKTOP, Hyprland"
          "GDK_BACKEND, wayland, x11"
          "CLUTTER_BACKEND, wayland"
          "QT_QPA_PLATFORM=wayland;xcb"
          "QT_WAYLAND_DISABLE_WINDOWDECORATION, 1"
          "QT_AUTO_SCREEN_SCALE_FACTOR, 1"
          "SDL_VIDEODRIVER, x11"
          "MOZ_ENABLE_WAYLAND, 1"
        ];
      };
    };
  };
}
