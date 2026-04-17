{
  inputs,
  pkgs,
  ...
}:
let
  unstable = import inputs.unstable {
    system = pkgs.stdenv.hostPlatform.system;
    config = {
      allowUnfree = false;
      allowUnfreePredicate =
        pkg:
        builtins.elem (pkgs.lib.getName pkg) [
          "claude-code"
        ];
    };
  };
in
{
  home.packages = with pkgs; [
    docker
    unstable.colima
    nmap
    tmate
    visidata

    unstable.claude-code
    claude-monitor
    unstable.pi-coding-agent

    spotify
    slack
    zoom-us
  ];

  programs.java = {
    enable = true;
    package = pkgs.jdk;
  };
}
