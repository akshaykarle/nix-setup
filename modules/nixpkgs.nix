{ inputs, config, lib, pkgs, ... }: {
  nixpkgs = { config = import ./config.nix; };

  nix = {
    package = pkgs.nix;
    extraOptions = ''
      keep-outputs = true
      keep-derivations = true
      experimental-features = nix-command flakes
    '';
    settings = {
      max-jobs = 8;
      trusted-users = [ "${config.user.name}" "root" "@admin" "@wheel" ];
    };
    optimise = {
      automatic = true;
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 30d";
    };

    nixPath = builtins.map
      (source: "${source}=/etc/${config.environment.etc.${source}.target}") [
        "home-manager"
        "nixpkgs"
        "stable"
      ];
    registry = {
      nixpkgs = {
        from = {
          id = "nixpkgs";
          type = "indirect";
        };
        to = {
          id = "nixpkgs";
          type = "indirect";
        };
        flake = inputs.stable;
      };
      stable = {
        from = {
          id = "stable";
          type = "indirect";
        };
        flake = inputs.stable;
      };
    };
  };
}
