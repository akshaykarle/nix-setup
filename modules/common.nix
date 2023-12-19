{ self, inputs, config, pkgs, ... }: {
  imports = [ ./nixpkgs.nix ];

  users.users.akshaykarle = {
    description = "Akshay Karle";
    home =
      "${if pkgs.stdenvNoCC.isDarwin then "/Users" else "/home"}/akshaykarle";
    shell = pkgs.fish;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.akshaykarle = import ./home-manager;
    extraSpecialArgs = { inherit self inputs; };
  };

  programs = { man.enable = true; fish.enable = true; };
}
