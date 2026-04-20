{
  config,
  lib,
  pkgs,
  mkUnstablePkgs,
  ...
}:
let
  unstablePkgs = mkUnstablePkgs pkgs.stdenv.hostPlatform.system {
    permittedInsecurePackages = [ "openclaw-2026.4.2" ];
  };
in
{
  containers.openclaw = {
    autoStart = true;
    privateNetwork = true;
    hostAddress = "10.233.2.1";
    localAddress = "10.233.2.2";

    bindMounts = {
      "/var/lib/openclaw" = {
        hostPath = "/var/lib/openclaw";
        isReadOnly = false;
      };
    };

    config =
      { config, pkgs, ... }:
      {
        system.stateVersion = "23.11";

        environment.systemPackages = [ unstablePkgs.openclaw ];

        # OpenClaw systemd service
        # Configure API keys and HA connection in /var/lib/openclaw/.env
        systemd.services.openclaw = {
          description = "OpenClaw AI Agent";
          after = [ "network.target" ];
          wantedBy = [ "multi-user.target" ];
          serviceConfig = {
            ExecStart = "${unstablePkgs.openclaw}/bin/openclaw";
            WorkingDirectory = "/var/lib/openclaw";
            DynamicUser = true;
            StateDirectory = "openclaw";
            NoNewPrivileges = true;
            ProtectSystem = "strict";
            ProtectHome = true;
            PrivateDevices = true;
            PrivateTmp = true;
            ReadWritePaths = [ "/var/lib/openclaw" ];
          };
          environment = {
            HASS_SERVER = "http://10.233.2.1:8123";
            HASS_TOKEN_FILE = "/var/lib/openclaw/ha-token";
          };
        };

        networking = {
          firewall.enable = true;
          firewall.allowedTCPPorts = [ 18789 ]; # OpenClaw Control UI
          useHostResolvConf = lib.mkForce true;
        };
      };
  };

  # Host-side NAT for OpenClaw container
  networking.nat = {
    enable = true;
    internalInterfaces = [ "ve-openclaw" ];
    externalInterface = "enp1s0";
  };

  # Network restrictions: OpenClaw can only reach HA API + LLM APIs
  networking.firewall.extraCommands = ''
    # Allow OpenClaw -> Host HA API (port 8123)
    iptables -I FORWARD -s 10.233.2.0/24 -d 10.233.2.1 -p tcp --dport 8123 -j ACCEPT
    # Allow established/related return traffic
    iptables -I FORWARD -m conntrack --ctstate ESTABLISHED,RELATED -j ACCEPT
    # Allow OpenClaw outbound HTTPS (for LLM API calls)
    iptables -I FORWARD -s 10.233.2.0/24 ! -d 10.233.0.0/16 -p tcp --dport 443 -j ACCEPT
    # Allow DNS to host resolver
    iptables -I FORWARD -s 10.233.2.0/24 -d 10.233.2.1 -p udp --dport 53 -j ACCEPT
    # Drop everything else from OpenClaw
    iptables -A FORWARD -s 10.233.2.0/24 -j DROP
  '';

  # Resource limits for OpenClaw container
  systemd.services."container@openclaw".serviceConfig = {
    MemoryMax = "2G";
    CPUQuota = "200%";
    TasksMax = 256;
  };

  # Ensure persistent directory exists
  systemd.tmpfiles.rules = [
    "d /var/lib/openclaw 0750 root root -"
  ];
}
