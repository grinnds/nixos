{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    ncfg.sesh.enable = lib.mkEnableOption "Enable sesh";
  };

  config = lib.mkIf config.ncfg.sesh.enable {
    home.packages = with pkgs; [
      sesh
    ];

    # required for sesh
    ncfg.zoxide.enable = true;

    xdg.configFile."sesh/sesh.toml" = {
      source = config.lib.file.mkOutOfStoreSymlink ./sesh.toml;
    };

    programs.tmux = {
      plugins = with pkgs.tmuxPlugins; [
        tmux-fzf
      ];

      # Clean up config
      extraConfig = ''
        bind-key x kill-pane # skip "kill-pane 1? (y/n)" prompt
        set -g detach-on-destroy off  # don't exit from tmux when closing a session

        bind-key "T" run-shell "sesh connect \"$(
          ${pkgs.sesh}/bin/sesh list --icons | fzf-tmux -p 80%,70% \
            --no-sort --ansi --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^g configs ^x zoxide ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(⚡  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}'
        )\""

        bind-key "K" display-popup -E -w 40% "sesh connect \"$(
          ${pkgs.sesh}/bin/sesh list -i | ${pkgs.gum}/bin/gum filter --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡'
        )\""

        bind -N "last-session (via sesh) " L run-shell "sesh last"
      '';
    };
  };
}
