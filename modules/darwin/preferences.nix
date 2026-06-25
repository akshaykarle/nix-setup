{ config, ... }:
{
  system.defaults = {
    # login window settings
    loginwindow = {
      # show name instead of username
      SHOWFULLNAME = false;
    };

    # file viewer settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = true;
      _FXShowPosixPathInTitle = true;
      ShowStatusBar = true;
    };

    # trackpad settings
    trackpad = {
      # silent clicking = 0, default = 1
      ActuationStrength = 0;
      # enable tap to click
      Clicking = true;
      # firmness level, 0 = lightest, 2 = heaviest
      FirstClickThreshold = 1;
      # firmness level for force touch
      SecondClickThreshold = 1;
      TrackpadRightClick = true;
      TrackpadThreeFingerDrag = true;
    };

    # dock settings
    dock = {
      # auto show and hide dock
      autohide = true;
      # remove delay for showing dock
      autohide-delay = 0.0;
      # how fast is the dock showing animation
      autohide-time-modifier = 1.0;
      tilesize = 50;
      static-only = false;
      showhidden = false;
      show-recents = false;
      show-process-indicators = true;
      orientation = "bottom";
      mru-spaces = false;
      # only these apps pinned in the dock, in this order (Finder is implicit far-left)
      persistent-apps = [
        "/System/Applications/Calculator.app"
        "/Applications/Brave Browser.app"
        "/System/Applications/Calendar.app"
        "/Applications/iTerm.app"
        "/Applications/Claude.app"
        "/System/Applications/System Settings.app"
        "/Users/${config.user.name}/Applications/Home Manager Apps/Spotify.app"
        "/Applications/Signal.app"
      ];
      persistent-others = [ ];
    };

    NSGlobalDomain = {
      # allow key repeat
      ApplePressAndHoldEnabled = false;
      # delay before repeating keystrokes (minimal)
      InitialKeyRepeat = 10;
      # delay between repeated keystrokes upon holding a key
      KeyRepeat = 1;
      AppleShowAllExtensions = true;
      AppleShowScrollBars = "Automatic";
      "com.apple.trackpad.enableSecondaryClick" = true;
      # enable tap to click globally
      "com.apple.mouse.tapBehavior" = 1;
    };
  };

  # input sources are not exposed as a nix-darwin option, so set them directly
  system.defaults.CustomUserPreferences = {
    "com.apple.HIToolbox" = {
      AppleEnabledInputSources = [
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 250;
          "KeyboardLayout Name" = "British-PC";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 2;
          "KeyboardLayout Name" = "British";
        }
        {
          InputSourceKind = "Keyboard Layout";
          "KeyboardLayout ID" = 0;
          "KeyboardLayout Name" = "U.S.";
        }
      ];
    };
    # show the input-source menu in the top-right menu bar
    "com.apple.TextInputMenu" = {
      visible = true;
    };
  };

  system.keyboard = {
    enableKeyMapping = true;
    remapCapsLockToEscape = true;
  };

  networking = {
    applicationFirewall = {
      enable = true;
      enableStealthMode = true;
      blockAllIncoming = true;
    };
  };
}
