{...}: {
  homebrew = {
    enable = true;
    onActivation = {
        autoUpdate = false; # Don't update during rebuild
        # cleanup = "zap"; # Uninstall all programs not declared
        upgrade = true;
    };
    global = {
      brewfile = true;
    };
    brews = [
      "coreutils"
      "rg"
      "ack"
      "autoconf"
      "readline"
      "findutils"
      "libpng"
      "freetype"
      "openssl"
      "gnu-tar"
      "libtool"
      "htop-osx"
      "pkg-config"
      "libevent"
      "qt5"
      "xz"
      "watch"
      "nmap"
      "wget"
      # required for fish- https://github.com/franciscolourenco/done
      "terminal-notifier"
      {
        name = "emacs-plus";
        start_service = true;
        args = [ "with-spacemacs-icon" "with-native-comp"];
      }
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
      "d12frosted/emacs-plus"
    ];
    casks = [
      "brave-browser"
      "flycut"
      "iterm2"
      "openoffice"
      "signal"
      "spectacle"
      "steam"
      "vlc"
    ];
  };
}
