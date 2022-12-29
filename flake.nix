{
  description = "Nix system configurations of akshaykarle";

  inputs = {
    # package repos
    stable.url = "github:nixos/nixpkgs/nixos-22.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    small.url = "github:nixos/nixpkgs/nixos-unstable-small";

    # system management
    darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    darwin,
    home-manager,
    nixpkgs,
    ...
  }:
  let
    system = "x86_64-linux";
  in {
    homeConfigurations.akshaykarle = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        inherit system;
      };
      modules = [ ./modules/home-manager ];
      extraSpecialArgs = {inherit self inputs nixpkgs;};
    };

    # reference https://nix-community.github.io/home-manager/index.html#sec-flakes-nixos-module
    nixosConfigurations = {
      hostname = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          home-manager.nixosModules.home-manager
          {
            home-manager.users.akshaykarle = import ./modules/home;
          }
        ];
        specialArgs = {inherit self inputs nixpkgs;};
      };
    };
  };
}
