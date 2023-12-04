{ self, inputs, config, pkgs, ... }: {
  # See
  # https://discourse.nixos.org/t/home-manager-installed-apps-dont-show-up-in-applications-launcher/8523/2
  # https://github.com/nix-community/home-manager/issues/1439
  targets.genericLinux.enable = true;

  # temp fix as nix installer puts symlinks outside of XDG_DATA_DIRS and desktop files need to be executable in /nix/store
  # References: https://old.reddit.com/r/Ubuntu/comments/hh1eh9/ubuntu_refuses_to_run_thirdparty_desktop_files/fw7yv0e/
  # Copied from: https://github.com/nix-community/home-manager/issues/1439#issuecomment-1106208294
  home.activation = {
    linkDesktopApplications = {
      after = [ "writeBoundary" "createXdgUserDirectories" ];
      before = [ ];
      data = "/usr/bin/update-desktop-database";
    };
  };

  # environment setup
  # environment = {
  #   systemPackages = with pkgs; [
  #     glibcLocales
  #     coreutils-full
  #     virtualbox

  #     # gui apps
  #     signald
  #     brave
  #     libreoffice-fresh
  #     spotify
  #     vlc
  #   ];
  # };
}
