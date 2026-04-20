{
  pkgs,
  mkUnstablePkgs,
  ...
}:
let
  unstablePkgs = mkUnstablePkgs pkgs.stdenv.hostPlatform.system {
    allowUnfree = false;
    allowUnfreePredicate =
      pkg:
      builtins.elem (pkgs.lib.getName pkg) [
        "claude-code"
      ];
  };
in
{
  home.packages = with pkgs; [
    docker
    unstablePkgs.colima
    nmap
    tmate
    visidata

    unstablePkgs.claude-code
    claude-monitor
    unstablePkgs.pi-coding-agent

    spotify
    slack
    zoom-us
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };
}
