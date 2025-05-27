{
  inputs,
  config,
  pkgs,
  ...
}:
{
  # environment setup
  environment = {
    etc = {
      darwin.source = "${inputs.darwin}";
      nixpkgs.source = "${inputs.nixpkgs}";
      stable.source = "${inputs.stable}";
    };
  };

  # add current user as primaryUser while nix-darwin migrates to system-wide activation
  system.primaryUser = config.user.name;

  # auto manage nixbld users with nix darwin
  nix = {
    nixPath = [
      "darwin=/etc/${config.environment.etc.darwin.target}"
      "nixpkgs=/etc/${config.environment.etc.nixpkgs.target}"
      "stable=/etc/${config.environment.etc.stable.target}"
    ];
    extraOptions = ''
      extra-platforms = x86_64-darwin aarch64-darwin
    '';
  };

  security.pam.services.sudo_local.touchIdAuth = true;

  system.stateVersion = 5;

  # Set the knownUsers so that the default shell works: https://github.com/LnL7/nix-darwin/issues/1237#issuecomment-2562230471 &
  # https://github.com/LnL7/nix-darwin/issues/1237#issuecomment-2562242340
  users.users.${config.user.name}.uid = 501;
  users.knownUsers = [ config.user.name ];
}
