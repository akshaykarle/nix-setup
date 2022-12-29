{ self, inputs, config, pkgs, ... }:
let homeDir = "/home/akshaykarle";
in {
  home = {
    username = "akshaykarle";
    homeDirectory = "${homeDir}";
    stateVersion = "22.11";

    packages = with pkgs; [
      coreutils-full
      clojure
      curl
      docker
      emacs
      gawk
      git
      nixfmt
      nixpkgs-fmt
      openjdk
      openvpn
      poetry
      pre-commit
      ripgrep
      slack
      spotify
    ];
  };

  programs = {
    home-manager = {
      enable = true;
      path = "${homeDir}/.config/nixpkgs/modules/home-manager";
    };
    go.enable = true;
    gpg.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    man.enable = true;
  };
}
