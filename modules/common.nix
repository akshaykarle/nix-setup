{ self, inputs, config, pkgs, ... }: {
  imports = [ ./primaryUser.nix ./nixpkgs.nix ];

  user = {
    description = "Akshay Karle";
    home = "${
        if pkgs.stdenvNoCC.isDarwin then "/Users" else "/home"
      }/${config.user.name}";
    shell = pkgs.fish;
  };

  hm = { imports = [ ./home-manager ]; };

  # let nix manage home-manager profiles and use global nixpkgs
  home-manager = {
    extraSpecialArgs = { inherit self inputs; };
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "backup";
  };

  programs = {
    man.enable = true;
    fish.enable = true;
  };

  # environment setup
  environment = {
    systemPackages = with pkgs; [
      # editors
      vim
      emacs

      # standard toolset
      coreutils-full
      findutils
      diffutils
      curl
      wget
      git
      jq

      # helpful shell stuff
      bat
      fzf
      ripgrep
    ];
    etc = {
      home-manager.source = "${inputs.home-manager}";
      nixpkgs.source = "${inputs.nixpkgs}";
      stable.source = "${inputs.stable}";
    };
    # list of acceptable shells in /etc/shells
    shells = with pkgs; [ fish zsh bash ];
  };

}
