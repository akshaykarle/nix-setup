{
  self,
  inputs,
  config,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./nvim.nix
    ./1password.nix
    ./claude.nix
    ./fish.nix
    ./pi.nix
    ./supply-chain-security.nix
  ];

  # Required to get the fonts installed by home-manager to be picked up by OS.
  fonts.fontconfig.enable = true;

  home = {
    stateVersion = "23.11";

    packages =
      with pkgs;
      [
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
        tmux
        nix-output-monitor
        tailscale
        gh

        # fonts
        nerd-fonts.sauce-code-pro # Nerd Font variant of Source Code Pro ("SauceCodePro") — required for nvim icons

        # languages & tools related to them
        cmake
        ctags
        nixfmt-rfc-style
        nixpkgs-fmt
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        neovide
      ];

    file = {
      gitignore = {
        source = ../../dotfiles/gitignore.symlink;
        target = ".gitignore";
      };
      gitconfig = {
        source = ../../dotfiles/gitconfig.symlink;
        target = ".gitconfig";
      };
      tmux = {
        source = ../../dotfiles/tmux.conf.symlink;
        target = ".tmux.conf";
      };
      lein = {
        source = ../../dotfiles/lein.symlink;
        target = ".lein";
        recursive = true;
      };
    };
  };

  programs = {
    man.generateCaches = false;
    home-manager = {
      enable = true;
      # path = "$HOME/.config/nixpkgs/modules/home-manager";
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
