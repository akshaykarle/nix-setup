{ config, ... }:
{
  # Enable Tailscale daemon
  services.tailscale = {
    enable = true;
    # Enable Tailscale SSH and advertise server tag for ACL targeting
    extraSetFlags = [
      "--ssh"
      "--advertise-tags=tag:home-server"
    ];
  };

  # Firewall: trust Tailscale interface, allow WireGuard UDP traffic
  networking.firewall = {
    trustedInterfaces = [ "tailscale0" ];
    allowedUDPPorts = [ config.services.tailscale.port ];
  };

  # OpenSSH as fallback (only accessible via Tailscale due to firewall)
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
}
