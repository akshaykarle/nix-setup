{ ... }:
{
  homebrew.casks = [
    "dropbox"
    "google-drive"
    "openoffice"
    "steam"
    "vlc"
  ];

  hm.imports = [ ../modules/home-manager/extras.nix ];

  user.name = "akshaykarle";
  user.description = "Akshay Karle";
}
