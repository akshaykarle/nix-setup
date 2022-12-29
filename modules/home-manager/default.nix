{ self, inputs, config, pkgs, ... }:
let homeDir = "/home/akshaykarle";
in {
  home = {
    username = "akshaykarle";
    homeDirectory = "${homeDir}";
    stateVersion = "22.11";

    packages = with pkgs; [
      # standard toolset
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
  };

  programs = {
    home-manager = {
      enable = true;
      path = "${homeDir}/.config/nixpkgs/modules/home-manager";
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
