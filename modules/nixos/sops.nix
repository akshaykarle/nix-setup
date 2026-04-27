{ config, ... }:
{
  sops = {
    defaultSopsFile = ../../secrets/passwords.yaml;
    age.sshKeyPaths = [ "/home/${config.user.name}/.ssh/id_ed25519" ];

    secrets."user-password-${config.user.name}" = {
      neededForUsers = true;
    };
  };

  users.users.${config.user.name}.hashedPasswordFile =
    config.sops.secrets."user-password-${config.user.name}".path;
}
