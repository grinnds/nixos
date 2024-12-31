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

    # Taken from: https://github.com/p3t33/nixos_flake/blob/fef092462c7df428495455d994154e940054a479/modules/home-manager/tmux.nix
    programs.tmux =
      let
        resurrectDirPath = "~/.config/tmux/resurrect";
      in
      {
        enable = true;

        shortcut = "a";
        baseIndex = 1;
        newSession = true;
        escapeTime = 0;
        keyMode = "vi";
        terminal = "tmux-256color";
        focusEvents = true;

        sensibleOnTop = true;
        plugins = with pkgs.tmuxPlugins; [
          yank
          {
            plugin = catppuccin;
            extraConfig = ''
              set -g @catppuccin_flavor "mocha"

              # Taken from https://github.com/catppuccin/tmux/discussions/317#discussioncomment-11064512
              # Colors not working
              # set -g @catppuccin_status_background "none"
              # set -g @catppuccin_window_status_style "none"
              # set -g @catppuccin_pane_status_enabled "off"
              # set -g @catppuccin_pane_border_status "off"
            '';
          }
          {
            plugin = online-status;
            extraConfig = ''
              # Hack for updating status line after catppuccin

              # # Configure Online
              # set -g @online_icon "ok"
              # set -g @offline_icon "nok"

              # # status left look and feel
              # set -g status-left-length 100
              # set -g status-left ""
              # set -ga status-left "#{?client_prefix,#{#[bg=#{@thm_red},fg=#{@thm_bg},bold]  #S },#{#[bg=#{@thm_bg},fg=#{@thm_green}]  #S }}"
              # set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
              # set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_maroon}]  #{pane_current_command} "
              # set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]│"
              # set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_blue}]  #{=/-32/...:#{s|$USER|~|:#{b:pane_current_path}}} "
              # set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_overlay_0},none]#{?window_zoomed_flag,│,}"
              # set -ga status-left "#[bg=#{@thm_bg},fg=#{@thm_yellow}]#{?window_zoomed_flag,  zoom ,}"

              # # status right look and feel
              # set -g status-right-length 100
              # set -g status-right ""
              # set -ga status-right "#{?#{e|>=:10,#{battery_percentage}},#{#[bg=#{@thm_red},fg=#{@thm_bg}]},#{#[bg=#{@thm_bg},fg=#{@thm_pink}]}} #{battery_icon} #{battery_percentage} "
              # set -ga status-right "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}, none]│"
              # set -ga status-right "#[bg=#{@thm_bg}]#{?#{==:#{online_status},ok},#[fg=#{@thm_mauve}] 󰖩 on ,#[fg=#{@thm_red},bold]#[reverse] 󰖪 off }"
              # set -ga status-right "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}, none]│"
              # set -ga status-right "#[bg=#{@thm_bg},fg=#{@thm_blue}] 󰭦 %Y-%m-%d 󰅐 %H:%M "

              # # Configure Tmux
              # set -g status-position top
              # set -g status-style "bg=#{@thm_bg}"
              # set -g status-justify "absolute-centre"

              # # pane border look and feel
              # setw -g pane-border-status top
              # setw -g pane-border-format ""
              # setw -g pane-active-border-style "bg=#{@thm_bg},fg=#{@thm_overlay_0}"
              # setw -g pane-border-style "bg=#{@thm_bg},fg=#{@thm_surface_0}"
              # setw -g pane-border-lines single

              # # window look and feel
              # set -wg automatic-rename on
              # set -g automatic-rename-format "Window"

              # set -g window-status-format " #I#{?#{!=:#{window_name},Window},: #W,} "
              # set -g window-status-style "bg=#{@thm_bg},fg=#{@thm_rosewater}"
              # set -g window-status-last-style "bg=#{@thm_bg},fg=#{@thm_peach}"
              # set -g window-status-activity-style "bg=#{@thm_red},fg=#{@thm_bg}"
              # set -g window-status-bell-style "bg=#{@thm_red},fg=#{@thm_bg},bold"
              # set -gF window-status-separator "#[bg=#{@thm_bg},fg=#{@thm_overlay_0}]│"

              # set -g window-status-current-format " #I#{?#{!=:#{window_name},Window},: #W,} "
              # set -g window-status-current-style "bg=#{@thm_peach},fg=#{@thm_bg},bold"

              # run /nix/store/aiva6d5ig81xmb6127xd2mciprp7sxh6-tmuxplugin-catppuccin-unstable-2024-05-15/share/tmux-plugins/catppuccin/catppuccin.tmux
            '';
          }
          battery
          # This plugin needs to be loaded before continuum or else continuum, will
          # not work.
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-nvim "session"
              set -g @resurrect-capture-pane-contents off

              # This three lines are specific to NixOS and they are intended
              # to edit the tmux_resurrect_* files that are created when tmux
              # session is saved using the tmux-resurrect plugin. Without going
              # into too much details the strings that are saved for some applications
              # such as nvim, vim, man... when using NixOS, appimage, asdf-vm into the
              # tmux_resurrect_* files can't be parsed and restored. This addition
              # makes sure to fix the tmux_resurrect_* files so they can be parsed by
              # the tmux-resurrect plugin and successfully restored.
              set -g @resurrect-dir ${resurrectDirPath}
              set -g @resurrect-hook-post-save-all 'sed -i -E "s|(pane.*nvim\s*:)[^;]+;.*\s([^ ]+)$|\1nvim \2|" ${resurrectDirPath}/last'
            '';
          }
          {
            plugin = continuum;
            extraConfig = ''
              set -g @continuum-restore on
              set -g @continuum-save-interval "10"
            '';
          }
        ];

        # TODO: Move to config file
        extraConfig = ''
          # This command is executed to address an edge case where after a fresh install of the OS no resurrect
          # directory exist which means that the continuum plugin will not work. And so without user
          # manually saving the first session(prfix + Ctrl+s) no resurrect-continuum will occur.
          #
          # And in case user does not remember to save his work for the first time and tmux daemon gets
          # restarted next time user will try to attach, there will be no state to attach to and user will
          # be scratching his head as to why.
          #
          # Saving right after fresh install on first boot of the tmux daemon with no sessions will create an
          # empty "last" session file which might cause all kind of issues if tmux gets restarted before
          # the user had the chance to work in it and let continuum plugin to take over and create
          # at least one valid "snapshot" from which tmux will be able to resurrect. This is why an initial
          # session named init-resurrect is created for resurrect plugin to create a valid "last" file for
          # continuum plugin to work off of.
          run-shell "if [ ! -d ${resurrectDirPath} ]; then tmux new-session -d -s init-resurrect; ${pkgs.tmuxPlugins.resurrect}/share/tmux-plugins/resurrect/scripts/save.sh; fi"

          # Why I don't enable "set-option -g set-clipboard on"
          # Some termenals are able to sync tmux internal copy buffer with the OS clipboard
          # This options enables thus function. From what I see regadless most yank related
          # plugins use tools like xclip so not to depend on the graces of the terminal.
          # In order to avoid conflicts between the plugins and this option it should
          # not be enabled.

          bind-key h select-pane -L
          bind-key j select-pane -D
          bind-key k select-pane -U
          bind-key l select-pane -R

          set -g renumber-windows on

          set -ag terminal-overrides ",xterm-256color:RGB"
        '';
      };
  };
}
