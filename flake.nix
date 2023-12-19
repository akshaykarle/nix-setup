{
  description = "Nix system configurations of akshaykarle";

  inputs = {
    # package repos
    stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

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

  outputs = inputs@{ self, darwin, home-manager, nixpkgs, ... }: {
    homeConfigurations.akshaykarle = home-manager.lib.homeManagerConfiguration {
      pkgs = import nixpkgs {
        system = "x86_64-linux";
        config = import ./modules/config.nix;
      };
      modules = [
        ./modules/home-manager
        {
          home = {
            username = "akshaykarle";
            homeDirectory = "/home/akshaykarle";
          };
        }
      ];
      extraSpecialArgs = { inherit self inputs nixpkgs; };
    };

    nixosConfigurations.akshaykarle = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.users.akshaykarle =
            import ./modules/home-manager/default.nix;
        }
        ./modules/linux
        inputs.nixos-hardware.nixosModules.common-gpu-nvidia
        inputs.nixos-hardware.nixosModules.common-cpu-amd
      ];
      specialArgs = { inherit self inputs nixpkgs; };
    };

    # reference https://nix-community.github.io/home-manager/index.html#sec-install-nix-darwin-module
    darwinConfigurations.akshaykarle = darwin.lib.darwinSystem {
      system = "x86_64-darwin";
      modules = [ home-manager.darwinModules.home-manager ./modules/darwin ];
      specialArgs = { inherit self inputs nixpkgs; };
    };
  };
}
