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
      enableZshIntegration = true;
    };

    programs.zsh = {
      enable = true;

      history = {
        append = true;
        ignoreAllDups = true;
        share = true;
        ignoreSpace = true;
      };

      initExtra = ''
        bindkey "^y" autosuggest-accept
        bindkey "^n" history-search-forward
        bindkey "^p" history-search-backward

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
      ];
    };
  };
}
