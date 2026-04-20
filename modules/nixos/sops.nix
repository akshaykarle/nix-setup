{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/passwords.yaml;
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

    secrets."user-password-${config.user.name}" = {
      neededForUsers = true;
    };
  };

  users.users.${config.user.name}.hashedPasswordFile =
    config.sops.secrets."user-password-${config.user.name}".path;
}
