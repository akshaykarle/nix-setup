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
      gawk
      git
      ripgrep

      # helpful tools
      docker
      openvpn
      nixfmt
      nixpkgs-fmt
      rnix-lsp
      poetry
      pre-commit
      emacs

      # languages
      python3
      ruby
      clojure

      # gui apps
      slack
      spotify
    ];

    file = {
      fishconfig = {
        source = ../../dotfiles/config.fish.symlink;
        target = ".config/fish/config.fish";
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
      path = "${homeManagerPath}";
    };
    java = {
      enable = true;
      package = pkgs.jdk;
    };
    go.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    man.enable = true;
  };
}
