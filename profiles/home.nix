{ ... }:
{
  imports = [
    ../modules/nixos/tailscale.nix
    ../modules/nixos/home-assistant.nix
    ../modules/nixos/openclaw-container.nix
    ../modules/nixos/desktop-minimal.nix
  ];

  # Allow SSH on local network interfaces (check with 'ip addr' and remove unused)
  services.tailscale-ssh.lanInterfaces = [
    "enp1s0"
    "wlo1"
  ];

  user.name = "daksh-home";
  user.description = "Daksh Home";
}
