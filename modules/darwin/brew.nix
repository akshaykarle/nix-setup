{...}: {
  homebrew = {
    enable = true;
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
    ];

    taps = [
      "homebrew/bundle"
      "homebrew/cask-fonts"
      "homebrew/cask-versions"
      "homebrew/services"
    ];
    casks = [
      "brave-browser"
      "flycut"
      "openoffice"
      "signal"
      "spectacle"
      "steam"
      "vlc"
    ];
  };
}
