{
  self,
  inputs,
  config,
  pkgs,
  ...
}:
{
  # Required to get the fonts installed by home-manager to be picked up by OS.
  fonts.fontconfig.enable = true;

  nixpkgs.config.allowUnfreePredicate =
    pkg:
    builtins.elem (pkgs.lib.getName pkg) [
      "ngrok"
      "postman"
      "terraform"
      "vscode"
      "obsidian"
      "slack"
      "1password"
      "spotify"
      "zoom"
    ];

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
      colima # docker alternative for osx
      nmap
      ngrok
      openvpn
      postman
      pre-commit
      tmux
      tmate
      postman
      nix-output-monitor

      # IDEs & editors
      emacs
      dbeaver-bin
      jetbrains.idea-community-bin
      vscode
      vim

      # languages & tools related to them
      cmake
      ctags
      nixfmt-rfc-style
      nixpkgs-fmt

      # gui apps
      _1password-gui
      obsidian
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
          rev = "ec74a24d6ad1ed74917f6eed32136715781e3f37";
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
      };
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    go.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
  };
}
