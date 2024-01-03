{ self, inputs, config, pkgs, ... }: {
  # Required to get the fonts installed by home-manager to be picked up by OS.
  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "23.11";

    packages = with pkgs; [
      # standard toolset
      curl
      findutils
      gnutar
      gawk
      git
      openssl
      ripgrep
      unixtools.watch

      # helpful tools
      docker
      colima # docker alternative for osx
      nmap
      ngrok
      openvpn
      pre-commit
      tmux
      tmate
      terraform

      # IDEs & editors
      emacs
      dbeaver
      jetbrains.idea-community
      vscode
      vim

      # languages & tools related to them
      cmake
      ctags
      python3
      poetry
      ruby
      clojure
      clojure-lsp
      go
      gotags
      nodejs
      nixfmt
      nixpkgs-fmt
      rnix-lsp

      # databases
      postgresql

      # gui apps
      _1password-gui
      brave
      libreoffice-fresh
      signald
      slack
      spotify
      vlc
      zoom-us
    ];

    file = {
      vundle = {
        source = builtins.fetchGit {
          url = "https://github.com/gmarik/Vundle.vim";
          rev = "0765c5c4f485fa111f190e2d7dd89ec9f5b3f554";
        };
        target = ".vim/bundle/Vundle.vim";
        recursive = true;
      };
      emacs_d = {
        source = builtins.fetchGit {
          url = "https://github.com/syl20bnr/spacemacs";
          rev = "8f7019340ec38c2cd70df37739a0adf77ff1e788";
        };
        target = ".emacs.d";
        recursive = true;
      };
      fishplugins = {
        source = ../../dotfiles/fish_plugins.symlink;
        target = ".config/fish/fish_plugins";
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
        generate-new-mac-address =
          "openssl rand -hex 6 | sed 's/(..)/1:/g; s/.$//' | xargs sudo ifconfig $1 ether";
        global-search-replace =
          "ack $1 -l --print0 | xargs -0 sed -i '' \"s/$1/$2/g\"";
      };
      shellAliases = {
        g = "git";
        d = "docker";
        k = "kubectl";
        tf = "terraform";
        gh =
          "open (git remote -v | awk '/fetch/{print $2}' | sed -Ee 's#(git@|git://)#http://#' -e 's@com:@com/@')| head -n1";
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
