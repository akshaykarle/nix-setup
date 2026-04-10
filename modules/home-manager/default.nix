{
  self,
  inputs,
  config,
  pkgs,
  ...
}:
let
  unstable = import inputs.unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = false;
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "claude-code"
        ];
    };
  };
in
{
  # Required to get the fonts installed by home-manager to be picked up by OS.
  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "23.11";

    packages = with pkgs; [
      # standard toolset
      curl
      diffutils
      findutils
      gnutar
      gawk
      git
      jq
      openssl
      ripgrep
      wget
      unixtools.watch

      # helpful tools
      docker
      unstable.colima # docker alternative for osx, use unstable for newer lima
      nmap
      ngrok
      tmux
      tmate
      nix-output-monitor
      tailscale
      unstable.claude-code
      claude-monitor
      visidata

      # IDEs & editors
      (if pkgs.stdenv.isDarwin then emacs.override { withNativeCompilation = false; } else emacs)
      vim

      # languages & tools related to them
      cmake
      ctags
      nixfmt-rfc-style
      nixpkgs-fmt

      # gui apps
      spotify
      slack
      zoom-us
    ];

    file = {
      vundle = {
        source = builtins.fetchGit {
          url = "https://github.com/gmarik/Vundle.vim";
          rev = "5548a1a937d4e72606520c7484cd384e6c76b565";
        };
        target = ".vim/bundle/Vundle.vim";
        recursive = true;
      };
      emacs_d = {
        source = builtins.fetchGit {
          url = "https://github.com/syl20bnr/spacemacs";
          rev = "610d900767b35228b5a2eb79f2a8de9596a5a264";
        };
        target = ".emacs.d";
        recursive = true;
      };
      gitignore = {
        source = ../../dotfiles/gitignore.symlink;
        target = ".gitignore";
      };
      gitconfig = {
        source = ../../dotfiles/gitconfig.symlink;
        target = ".gitconfig";
      };
      spacemacs = {
        source = ../../dotfiles/spacemacs.symlink;
        target = ".spacemacs";
      };
      tmux = {
        source = ../../dotfiles/tmux.conf.symlink;
        target = ".tmux.conf";
      };
      vimrc = {
        source = ../../dotfiles/vimrc.symlink;
        target = ".vimrc";
      };
      lein = {
        source = ../../dotfiles/lein.symlink;
        target = ".lein";
        recursive = true;
      };
      claude-personal-statusline = {
        source = ../../dotfiles/claude-statusline.sh;
        target = ".claude-personal/statusline-command.sh";
        executable = true;
      };
      claude-personal-settings = {
        target = ".claude-personal/settings.json";
        text = builtins.toJSON {
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-personal/statusline-command.sh";
          };
        };
      };
      claude-sahaj-statusline = {
        source = ../../dotfiles/claude-statusline.sh;
        target = ".claude-sahaj/statusline-command.sh";
        executable = true;
      };
      claude-sahaj-settings = {
        target = ".claude-sahaj/settings.json";
        text = builtins.toJSON {
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-sahaj/statusline-command.sh";
          };
        };
      };
      claude-client-statusline = {
        source = ../../dotfiles/claude-statusline.sh;
        target = ".claude-client/statusline-command.sh";
        executable = true;
      };
      claude-client-settings = {
        target = ".claude-client/settings.json";
        text = builtins.toJSON {
          enabledPlugins = {
            "csharp-lsp@claude-plugins-official" = true;
          };
          alwaysThinkingEnabled = true;
          statusLine = {
            type = "command";
            command = "${config.home.homeDirectory}/.claude-client/statusline-command.sh";
          };
        };
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
      # path = "$HOME/.config/nixpkgs/modules/home-manager";
    };
    java = {
      enable = true;
      package = pkgs.jdk;
    };
    fish = {
      enable = true;
      plugins = with pkgs.fishPlugins; [
        {
          name = "bass";
          src = bass.src;
        }
        {
          name = "colored-man-pages";
          src = colored-man-pages.src;
        }
        {
          name = "done";
          src = done.src;
        }
        {
          name = "z";
          src = z.src;
        }
      ];
      shellInit = ''
        set fish_greeting

        # Source custom scripts
        if test -e $HOME/.config/fish/custom
            source $HOME/.config/fish/custom/*.fish
        end

        # Source secret envs :
        if test -e $HOME/.config/fish/secret.fish
            source $HOME/.config/fish/secret.fish
        end

        # Add homebrew to the PATH:
        if test -e /opt/homebrew/bin/brew
            eval "$(/opt/homebrew/bin/brew shellenv)"
        end
      '';
      functions = {
        wifi-password-finder = "security find-generic-password -gwa $1";
        generate-new-mac-address = "openssl rand -hex 6 | sed 's/(..)/1:/g; s/.$//' | xargs sudo ifconfig $1 ether";
        global-search-replace = "ack $1 -l --print0 | xargs -0 sed -i '' \"s/$1/$2/g\"";
      };
      shellAliases = {
        g = "git";
        d = "docker";
        k = "kubectl";
        tf = "terraform";
        gh = "open (git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@')| head -n1";
        claude-personal = "CLAUDE_CONFIG_DIR=~/.claude-personal claude";
        claude-sahaj = "CLAUDE_CONFIG_DIR=~/.claude-sahaj claude";
        claude-client = "CLAUDE_CONFIG_DIR=~/.claude-client claude";
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
      package = pkgs.direnv.overrideAttrs (old: {
        checkPhase = ''
          runHook preCheck
          make test-go test-bash test-zsh
          runHook postCheck
        '';
      });
    };
    go.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
  };
}
