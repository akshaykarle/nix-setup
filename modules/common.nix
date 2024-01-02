{ self, inputs, config, pkgs, ... }: {
  imports = [ ./nixpkgs.nix ];

  user = {
    description = "Akshay Karle";
    home = "${
        if pkgs.stdenvNoCC.isDarwin then "/Users" else "/home"
      }/${config.user.name}";
    shell = pkgs.fish;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.akshaykarle = import ./home-manager;
    extraSpecialArgs = { inherit self inputs; };
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
