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
    home.packages = with pkgs; [
      # required for tmux-yank
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

              set -g @catppuccin_window_left_separator ""
              set -g @catppuccin_window_right_separator " "
              set -g @catppuccin_window_middle_separator " █"
              set -g @catppuccin_window_number_position "right"

              set -g @catppuccin_window_default_fill "number"
              set -g @catppuccin_window_default_text "#W"

              set -g @catppuccin_window_current_fill "number"
              set -g @catppuccin_window_current_text "#W"

              set -g @catppuccin_status_modules_right "session"
              set -g @catppuccin_status_left_separator  " "
              set -g @catppuccin_status_right_separator ""
              set -g @catppuccin_status_right_separator_inverse "no"
              set -g @catppuccin_status_fill "icon"
              set -g @catppuccin_status_connect_separator "no"

              set -g @catppuccin_directory_text "#{pane_current_path}"

              set -g @catppuccin_date_time_text "%Y-%m-%d %H:%M:%S"

              set -g @catppuccin_window_status_enable "yes"

              set -g @catppuccin_icon_window_last "󰖰"
              set -g @catppuccin_icon_window_current "󰖯"
              set -g @catppuccin_icon_window_zoom "󰁌"
              set -g @catppuccin_icon_window_mark "󰃀"
              set -g @catppuccin_icon_window_silent "󰂛"
              set -g @catppuccin_icon_window_activity "󰖲"
              set -g @catppuccin_icon_window_bell "󰂞"

              # This one is good https://github.com/catppuccin/tmux/discussions/317#discussioncomment-11064512
              # But I can't male it work, colors not working
              # Current look is fine
            '';
          }
          # This plugin needs to be loaded before continuum or else continuum, will
          # not work.
          {
            plugin = resurrect;
            extraConfig = ''
              set -g @resurrect-strategy-nvim "session"
              set -g @resurrect-capture-pane-contents on

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
              set -g @continuum-save-interval "1"
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

          bind-key -r M-h resize-pane -L 5
          bind-key -r M-j resize-pane -D 5
          bind-key -r M-k resize-pane -U 5
          bind-key -r M-l resize-pane -R 5

          # A more consistent(with i3wm) and ergonomic(qwerty) to focus on a pane
          unbind z
          bind-key f resize-pane -Z

          bind-key -T copy-mode-vi v send-keys -X begin-selection
          bind-key -T copy-mode-vi V send-keys -X select-line
          bind-key -T copy-mode-vi C-v run-shell "tmux send-keys -X rectangle-toggle; tmux send-keys -X begin-selection"

          bind-key -T copy-mode-vi y send-keys -X copy-selection

          set-option -g status-position top

          set -g renumber-windows on

          set -ag terminal-overrides ",xterm-256color:RGB"

          # Use w for sessions
          unbind s

          unbind %
          unbind '"'
          bind s split-window -h -c "#{pane_current_path}"
          bind v split-window -v -c "#{pane_current_path}"

          # Disabling wrapping will disable switching zoomed, because zoomed pane considered left,top,etc.
          is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
              | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|l?n?vim?x?|fzf)(diff)?$'"
          bind-key -n 'C-h' if-shell "$is_vim" { send-keys C-h } { if-shell -F '#{pane_at_left}'   {} { select-pane -LZ } }
          bind-key -n 'C-j' if-shell "$is_vim" { send-keys C-j } { if-shell -F '#{pane_at_bottom}' {} { select-pane -DZ } }
          bind-key -n 'C-k' if-shell "$is_vim" { send-keys C-k } { if-shell -F '#{pane_at_top}'    {} { select-pane -UZ } }
          bind-key -n 'C-l' if-shell "$is_vim" { send-keys C-l } { if-shell -F '#{pane_at_right}'  {} { select-pane -RZ } }

          bind-key -T copy-mode-vi 'C-h' if-shell -F '#{pane_at_left}'   {} { select-pane -LZ }
          bind-key -T copy-mode-vi 'C-j' if-shell -F '#{pane_at_bottom}' {} { select-pane -DZ }
          bind-key -T copy-mode-vi 'C-k' if-shell -F '#{pane_at_top}'    {} { select-pane -UZ }
          bind-key -T copy-mode-vi 'C-l' if-shell -F '#{pane_at_right}'  {} { select-pane -RZ }
        '';
      };
  };
}
