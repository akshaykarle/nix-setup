{
  self,
  inputs,
  config,
  pkgs,
  ...
}:
{
  imports = [
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
      tmux
      nix-output-monitor
      tailscale

      # IDEs & editors
      (if pkgs.stdenv.isDarwin then emacs.override { withNativeCompilation = false; } else emacs)
      vim

      # languages & tools related to them
      cmake
      ctags
      nixfmt-rfc-style
      nixpkgs-fmt
    ];

    file = {
      vundle = {
        source = inputs.vundle;
        target = ".vim/bundle/Vundle.vim";
        recursive = true;
      };
      emacs_d = {
        source = inputs.spacemacs;
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
