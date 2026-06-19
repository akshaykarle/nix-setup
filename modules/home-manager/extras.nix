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
    # visidata disabled: arrow-cpp-23.0.0 test failure in nixpkgs 26.05 (TestAzuriteGeneric.NormalizePath)
    # visidata

    unstablePkgs.claude-code
    claude-monitor
    unstablePkgs.pi-coding-agent
    nodejs_22

    spotify
    slack
    zoom-us
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };
}
