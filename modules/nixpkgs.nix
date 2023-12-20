{ inputs, config, lib, pkgs, ... }: {
  nixpkgs = { config = import ./config.nix; };

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = { max-jobs = 8; };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };
  };
}
