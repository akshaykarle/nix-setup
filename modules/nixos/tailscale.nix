{ config, lib, ... }:
let
  cfg = config.services.tailscale-ssh;
in
{
  options.services.tailscale-ssh = {
    lanInterfaces = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "LAN interfaces to allow SSH access on (in addition to Tailscale)";
      example = [ "enp1s0" "wlan0" ];
    };
  };

  config = {
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
      # Allow SSH on specified LAN interfaces
      interfaces = lib.genAttrs cfg.lanInterfaces (_: {
        allowedTCPPorts = [ 22 ];
      });
    };

    # OpenSSH as fallback (only accessible via Tailscale + LAN interfaces due to firewall)
    services.openssh = {
      enable = true;
      settings = {
        PasswordAuthentication = false;
        PermitRootLogin = "no";
      };
    };
  };
}
