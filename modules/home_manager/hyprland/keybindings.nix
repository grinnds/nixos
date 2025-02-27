{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.ncfg.hyprland;
  terminal = "wezterm";
  browser = "brave";
in
{
  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [
        "$modifier,Return,exec,${terminal}"
        "$modifier SHIFT,Return,exec,rofi-launcher"
        "$modifier,W,exec,${browser}"
        "$modifier,T,exec,pypr toggle term"
        "$modifier SHIFT,T,exec,pypr toggle thunar"
        "$modifier,backspace,exec,hyprlock"
        "$modifier,M,exec,pavucontrol"
        "$modifier,Q,killactive,"
        "$modifier,P,exec,pypr toggle volume"
        "$modifier SHIFT,P,pseudo,"
        "$modifier SHIFT,I,togglesplit,"
        "$modifier,F,fullscreen,"
        "$modifier SHIFT,F,togglefloating,"
        "$modifier SHIFT,C,exit,"
        "$modifier SHIFT,left,movewindow,l"
        "$modifier SHIFT,right,movewindow,r"
        "$modifier SHIFT,up,movewindow,u"
        "$modifier SHIFT,down,movewindow,d"
        "$modifier SHIFT,h,movewindow,l"
        "$modifier SHIFT,l,movewindow,r"
        "$modifier SHIFT,k,movewindow,u"
        "$modifier SHIFT,j,movewindow,d"
        "$modifier,left,movefocus,l"
        "$modifier,right,movefocus,r"
        "$modifier,up,movefocus,u"
        "$modifier,down,movefocus,d"
        "$modifier,h,movefocus,l"
        "$modifier,l,movefocus,r"
        "$modifier,k,movefocus,u"
        "$modifier,j,movefocus,d"
        "$modifier,1,workspace,1"
        "$modifier,2,workspace,2"
        "$modifier,3,workspace,3"
        "$modifier,4,workspace,4"
        "$modifier,5,workspace,5"
        "$modifier,6,workspace,6"
        "$modifier,7,workspace,7"
        "$modifier,8,workspace,8"
        "$modifier,9,workspace,9"
        "$modifier,0,workspace,10"
        "$modifier SHIFT,SPACE,movetoworkspace,special"
        "$modifier,SPACE,togglespecialworkspace"
        "$modifier SHIFT,1,movetoworkspace,1"
        "$modifier SHIFT,2,movetoworkspace,2"
        "$modifier SHIFT,3,movetoworkspace,3"
        "$modifier SHIFT,4,movetoworkspace,4"
        "$modifier SHIFT,5,movetoworkspace,5"
        "$modifier SHIFT,6,movetoworkspace,6"
        "$modifier SHIFT,7,movetoworkspace,7"
        "$modifier SHIFT,8,movetoworkspace,8"
        "$modifier SHIFT,9,movetoworkspace,9"
        "$modifier SHIFT,0,movetoworkspace,10"
        "$modifier CONTROL,right,workspace,e+1"
        "$modifier CONTROL,left,workspace,e-1"
        "$modifier,mouse_down,workspace, e+1"
        "$modifier,mouse_up,workspace, e-1"
        "ALT,Tab,cyclenext"
        "ALT,Tab,bringactivetotop"
      ];

      bindm = [
        "$modifier, mouse:272, movewindow"
        "$modifier, mouse:273, resizewindow"
      ];
    };
  };
}
