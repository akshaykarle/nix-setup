{ ... }:
{
  imports = [ ../modules/nixos/tailscale.nix ];

  # Allow SSH on local network interfaces (check with 'ip addr' and remove unused)
  services.tailscale-ssh.lanInterfaces = [ "enp1s0" "enp0s20f0u2" ];

  user.name = "daksh-home";
  user.description = "Daksh Home";
  user.hashedPassword = "$6$CJWhmoVMcH4T85FG$NXBIWLfmY2NN7cXdZH6QRYXu2meA1yznUTN5oiAjUCIL9kn7jzJkREA8.5/28EL1.AYT61Ui6FB1y..c5zYi6.";
}
