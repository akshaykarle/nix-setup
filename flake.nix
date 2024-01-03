{
  description = "Nix system configurations of akshaykarle";

  inputs = {
    # package repos
    stable.url = "github:nixos/nixpkgs/nixos-23.11";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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

  outputs = { self, darwin, home-manager, nixpkgs, ... }@inputs:
    let
      isDarwin = system:
        (builtins.elem system inputs.nixpkgs.lib.platforms.darwin);
      homePrefix = system: if isDarwin system then "/Users" else "/home";
      defaultSystems = [ "x86_64-darwin" "x86_64-linux" ];

      # generate a base darwin configuration with the
      # specified hostname, overlays, and any extraModules applied
      mkDarwinConfig = { system ? "x86_64-darwin", nixpkgs ? inputs.nixpkgs
        , baseModules ? [
          home-manager.darwinModules.home-manager
          ./modules/darwin
        ], extraModules ? [ ], }:
        inputs.darwin.lib.darwinSystem {
          inherit system;
          modules = baseModules ++ extraModules;
          specialArgs = { inherit self inputs nixpkgs; };
        };

      # generate a base nixos configuration with the
      # specified overlays, hardware modules, and any extraModules applied
      mkNixosConfig = { system ? "x86_64-linux", nixpkgs ? inputs.nixos-unstable
        , hardwareModules, baseModules ? [
          home-manager.nixosModules.home-manager
          ./modules/nixos
        ], extraModules ? [ ], }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = { inherit self inputs nixpkgs; };
        };

      # generate a home-manager configuration usable on any unix system
      # with overlays and any extraModules applied
      mkHomeConfig = { username, system ? "x86_64-linux"
        , nixpkgs ? inputs.nixpkgs, baseModules ? [
          ./modules/home-manager
          {
            home = {
              inherit username;
              homeDirectory = "${homePrefix system}/${username}";
              sessionVariables = {
                NIX_PATH =
                  "nixpkgs=${nixpkgs}:stable=${inputs.stable}\${NIX_PATH:+:}$NIX_PATH";
              };
            };
          }
        ], extraModules ? [ ], }:
        inputs.home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs { inherit system; };
          extraSpecialArgs = { inherit self inputs nixpkgs; };
          modules = baseModules ++ extraModules;
        };

      mkChecks = { arch, os, username ? "akshaykarle", }: {
        "${arch}-${os}" = {
          "${username}_${os}" = (if os == "darwin" then
            self.darwinConfigurations
          else
            self.nixosConfigurations)."${username}@${arch}-${os}".config.system.build.toplevel;
          "${username}_home" =
            self.homeConfigurations."${username}@${arch}-${os}".activationPackage;
        };
      };
    in {
      checks = { } // (mkChecks {
        arch = "x86_64";
        os = "darwin";
      }) // (mkChecks {
        arch = "aarch64";
        os = "linux";
      }) // (mkChecks {
        arch = "x86_64";
        os = "linux";
      });

      darwinConfigurations = {
        "akshaykarle@x86_64-darwin" = mkDarwinConfig {
          system = "x86_64-darwin";
          extraModules = [ ./profiles/personal.nix ];
        };
      };

      nixosConfigurations = {
        "akshaykarle@x86_64-linux" = mkNixosConfig {
          system = "x86_64-linux";
          hardwareModules = [ ./modules/hardware/asus.nix ];
          extraModules = [ ./profiles/personal.nix ];
        };
      };

      homeConfigurations = {
        "akshaykarle@x86_64-linux" = mkHomeConfig {
          username = "akshaykarle";
          system = "x86_64-linux";
          extraModules = [ ./modules/home-manager ];
        };
        "akshaykarle@x86_64-darwin" = mkHomeConfig {
          username = "akshaykarle";
          system = "x86_64-darwin";
          extraModules = [ ./modules/home-manager ];
        };
      };
    };
}
