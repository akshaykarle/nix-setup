{ self, inputs, config, pkgs, ... }:
let homeDir = "/home/akshaykarle";
in {
  nixpkgs.config = { allowUnfree = true; };

  home = {
    username = "akshaykarle";
    homeDirectory = "${homeDir}";
    stateVersion = "22.11";

    packages = with pkgs; [
      coreutils-full
      curl
      gawk
      git
      nixfmt
      nixpkgs-fmt
      poetry
      pre-commit
      ripgrep
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
