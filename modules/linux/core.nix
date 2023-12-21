{ self, inputs, config, pkgs, ... }: {
  environment = {
    systemPackages = with pkgs; [
      gnumake
      glibcLocales
      coreutils-full
      virtualbox

      # gui apps
      signald
      brave
      libreoffice-fresh
      spotify
      vlc
    ];
  };
}
