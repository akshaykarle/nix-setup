{
  description = "Nix system configurations of akshaykarle";

  inputs = {
    # package repos
    stable.url = "github:nixos/nixpkgs/nixos-25.11";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    # system management
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # dev tools
    git-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      darwin,
      git-hooks,
      home-manager,
      nixpkgs,
      unstable,
      ...
    }@inputs:
    let
      isDarwin = system: (builtins.elem system inputs.nixpkgs.lib.platforms.darwin);
      homePrefix = system: if isDarwin system then "/Users" else "/home";

      # generate a base darwin configuration with the
      # specified hostname, overlays, and any extraModules applied
      mkUnstablePkgs =
        system: extraConfig:
        import inputs.unstable {
          inherit system;
          config = {
            allowUnfree = true;
          }
          // extraConfig;
        };

      mkDarwinConfig =
        {
          system ? "aarch64-darwin",
          nixpkgs ? inputs.nixpkgs,
          baseModules ? [
            home-manager.darwinModules.home-manager
            ./modules/darwin
          ],
          extraModules ? [ ],
        }:
        darwin.lib.darwinSystem {
          inherit system;
          modules = baseModules ++ extraModules;
          specialArgs = {
            inherit
              self
              inputs
              nixpkgs
              mkUnstablePkgs
              ;
          };
        };

      # generate a base nixos configuration with the
      # specified overlays, hardware modules, and any extraModules applied
      mkNixosConfig =
        {
          system ? "x86_64-linux",
          nixpkgs ? inputs.stable,
          hardwareModules,
          baseModules ? [
            home-manager.nixosModules.home-manager
            ./modules/nixos
          ],
          extraModules ? [ ],
        }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = baseModules ++ hardwareModules ++ extraModules;
          specialArgs = {
            inherit
              self
              inputs
              nixpkgs
              mkUnstablePkgs
              ;
            unstablePkgs = mkUnstablePkgs system { };
          };
        };

      # generate a home-manager configuration usable on any unix system
      # with overlays and any extraModules applied
      mkHomeConfig =
        {
          username,
          system ? "x86_64-linux",
          nixpkgs ? inputs.nixpkgs,
          baseModules ? [
            ./modules/home-manager
            {
              home = {
                inherit username;
                homeDirectory = "${homePrefix system}/${username}";
                sessionVariables = {
                  NIX_PATH = "nixpkgs=${nixpkgs}:stable=${inputs.stable}\${NIX_PATH:+:}$NIX_PATH";
                };
              };
            }
          ],
          extraModules ? [ ],
        }:
        inputs.home-manager.lib.homeManagerConfiguration rec {
          pkgs = import nixpkgs {
            inherit system;
            config = import ./modules/config.nix;
          };
          extraSpecialArgs = {
            inherit
              self
              inputs
              nixpkgs
              mkUnstablePkgs
              ;
            unstablePkgs = mkUnstablePkgs system { };
          };
          modules = baseModules ++ extraModules;
        };

      supportedSystems = [
        "aarch64-darwin"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      mkPreCommitHooks =
        system:
        git-hooks.lib.${system}.run {
          src = ./.;
          hooks = {
            nixfmt-rfc-style.enable = true;
            actionlint.enable = true;
          };
        };

      mkChecks =
        {
          arch,
          os,
          username ? "akshaykarle",
        }:
        {
          "${arch}-${os}" = {
            "${username}_${os}" =
              (if os == "darwin" then self.darwinConfigurations else self.nixosConfigurations)
              ."${username}@${arch}-${os}".config.system.build.toplevel;
            "${username}_home" = self.homeConfigurations."${username}@${arch}-${os}".activationPackage;
          };
        };
    in
    {
      checks = nixpkgs.lib.foldl nixpkgs.lib.recursiveUpdate { } (
        [
          (mkChecks {
            arch = "aarch64";
            os = "darwin";
          })
          (mkChecks {
            arch = "x86_64";
            os = "darwin";
          })
          (mkChecks {
            arch = "x86_64";
            os = "linux";
          })
          (mkChecks {
            arch = "x86_64";
            os = "linux";
            username = "daksh-home";
          })
        ]
        ++ map (system: {
          ${system}.pre-commit = mkPreCommitHooks system;
        }) supportedSystems
      );

      devShells = builtins.listToAttrs (
        map (system: {
          name = system;
          value.default =
            let
              pkgs = import nixpkgs { inherit system; };
              pre-commit = mkPreCommitHooks system;
            in
            pkgs.mkShell {
              shellHook = pre-commit.shellHook;
              buildInputs = pre-commit.enabledPackages;
            };
        }) supportedSystems
      );

      darwinConfigurations = {
        "akshaykarle@x86_64-darwin" = mkDarwinConfig {
          system = "x86_64-darwin";
          extraModules = [ ./profiles/darwin.nix ];
        };
        "akshaykarle@aarch64-darwin" = mkDarwinConfig {
          system = "aarch64-darwin";
          extraModules = [ ./profiles/darwin.nix ];
        };
      };

      nixosConfigurations = {
        "akshaykarle@x86_64-linux" = mkNixosConfig {
          system = "x86_64-linux";
          hardwareModules = [ ./modules/hardware/asus.nix ];
          extraModules = [ ./profiles/personal.nix ];
        };
        "daksh-home@x86_64-linux" = mkNixosConfig {
          system = "x86_64-linux";
          hardwareModules = [ ./modules/hardware/intel.nix ];
          extraModules = [ ./profiles/home.nix ];
        };
      };

      homeConfigurations = {
        "akshaykarle@x86_64-linux" = mkHomeConfig {
          username = "akshaykarle";
          system = "x86_64-linux";
          extraModules = [ ./modules/home-manager/extras.nix ];
        };
        "daksh-home@x86_64-linux" = mkHomeConfig {
          username = "daksh-home";
          system = "x86_64-linux";
        };
        "akshaykarle@x86_64-darwin" = mkHomeConfig {
          username = "akshaykarle";
          system = "x86_64-darwin";
          extraModules = [ ./modules/home-manager/extras.nix ];
        };
        "akshaykarle@aarch64-darwin" = mkHomeConfig {
          username = "akshaykarle";
          system = "aarch64-darwin";
          extraModules = [ ./modules/home-manager/extras.nix ];
        };
      };
    };
}
