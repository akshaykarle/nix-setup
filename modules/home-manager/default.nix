{ self, inputs, config, pkgs, ... }:
let
  username = "akshaykarle";
  homeDirectory = "/home/akshaykarle";
  homeManagerPath = "${homeDirectory}/.config/nixpkgs/modules/home-manager";
in {
  # Required to get the fonts installed by home-manager to be picked up by OS.
  fonts.fontconfig.enable = true;

  # See
  # https://discourse.nixos.org/t/home-manager-installed-apps-dont-show-up-in-applications-launcher/8523/2
  # https://github.com/nix-community/home-manager/issues/1439
  targets.genericLinux.enable = true;

  home = {
    inherit username homeDirectory;
    stateVersion = "22.11";

    packages = with pkgs; [
      # standard toolset
      glibcLocales
      coreutils-full
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
      nmap
      ngrok
      openvpn
      pre-commit
      tmux
      tmate
      terraform
      virtualbox

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
    ];

    file = {
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

    # temp fix as nix installer puts symlinks outside of XDG_DATA_DIRS and desktop files need to be executable in /nix/store
    # References: https://old.reddit.com/r/Ubuntu/comments/hh1eh9/ubuntu_refuses_to_run_thirdparty_desktop_files/fw7yv0e/
    # Copied from: https://github.com/nix-community/home-manager/issues/1439#issuecomment-1106208294
    activation = {
      linkDesktopApplications = {
        after = [ "writeBoundary" "createXdgUserDirectories" ];
        before = [ ];
        data = ''
          rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          cp -Lr ${homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
        '';
      };
    };
  };

  programs = {
    home-manager = {
      enable = true;
      path = "${homeManagerPath}";
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

        # Source secret envs :)
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
    man.enable = true;
  };
}
