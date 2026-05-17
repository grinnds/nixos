{
  config,
  pkgs,
  lib,
  ...
}:

{
  options = {
    ncfg.zsh.enable = lib.mkEnableOption "Enable zsh";
  };

  config = lib.mkIf config.ncfg.zsh.enable {
    programs.fzf = lib.mkIf config.ncfg.fzf.enable {
      enableZshIntegration = false;
    };

    programs.zsh = {
      enable = true;

      history = {
        append = true;
        ignoreAllDups = true;
        share = true;
        ignoreSpace = true;
      };

      initContent = ''
        export OPENROUTER_API_KEY=$(cat ${config.sops.secrets.openrouter_api_key.path})

        # https://unix.stackexchange.com/questions/722697/how-to-stop-ctrlleft-right-arrow-from-erasing-symbols-in-vi-mode-in-zsh
        bindkey -M vicmd "^[[1;5C" emacs-forward-word
        bindkey -M vicmd "^[[1;5D" emacs-backward-word
        bindkey -M viins "^[[1;5C" emacs-forward-word
        bindkey -M viins "^[[1;5D" emacs-backward-word

        zstyle ":completion:*" matcher-list "m:{a-z}={A-Za-z}"
        zstyle ":completion:*" list-colors "$\{(s.:.)LS_COLORS}"
        zstyle ":completion:*" menu no 
        zstyle ":fzf-tab:complete:cd:*" fzf-preview 'ls --color $realpath'
      '';
      plugins = with pkgs; [
        {
          name = zsh-powerlevel10k.pname;
          src = zsh-powerlevel10k.src;
          file = "powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          src = ./config;
          file = "p10k.zsh";
        }
        # Should be before zsh-syntax-highlighting
        {
          name = "zsh-syntax-highlighting-catppuccin";
          src = fetchFromGitHub {
            owner = "catppuccin";
            repo = "zsh-syntax-highlighting";
            rev = "7926c3d";
            hash = "sha256-l6tztApzYpQ2/CiKuLBf8vI2imM6vPJuFdNDSEi7T/o=";
          };
          file = "themes/catppuccin_mocha-zsh-syntax-highlighting.zsh";
        }
        {
          name = zsh-syntax-highlighting.pname;
          src = zsh-syntax-highlighting.src;
        }
        {
          name = zsh-completions.pname;
          src = zsh-completions.src;
        }
        {
          name = zsh-autosuggestions.pname;
          src = zsh-autosuggestions.src;
        }
        {
          name = zsh-fzf-tab.pname;
          src = zsh-fzf-tab.src;
          file = "fzf-tab.plugin.zsh";
        }
        {
          name = "zsh-vi-mode-config";
          src = pkgs.writeTextDir "zsh-vi-mode-config.plugin.zsh" ''
            # Disable insert style for cursor
            ZVM_CURSOR_STYLE_ENABLED=false

            zvm_after_init_commands+=(
              'bindkey -M viins "^y" autosuggest-accept'
              'bindkey -M viins "^n" history-search-forward'
              'bindkey -M viins "^p" history-search-backward'
              ${lib.strings.optionalString config.ncfg.fzf.enable "'eval \"$(${pkgs.fzf}/bin/fzf --zsh)\"'"}
            )
          '';
          file = "zsh-vi-mode-config.plugin.zsh";
        }
        {
          name = zsh-vi-mode.pname;
          src = zsh-vi-mode.src;
        }
      ];
    };
  };
}
