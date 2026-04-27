{ ... }:
{
  imports = [ ../modules/nixos/extras.nix ];

  hm.imports = [ ../modules/home-manager/extras.nix ];

  user.name = "akshaykarle";
  user.description = "Akshay Karle";
}
