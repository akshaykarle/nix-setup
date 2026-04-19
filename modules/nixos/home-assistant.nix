{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:
let
  unstablePkgs = import inputs.unstable {
    system = "x86_64-linux";
    config.allowUnfree = true;
  };
in
{
  # Home Assistant — imperative config management initially
  # Existing YAML config is copied to /var/lib/hass and managed manually.
  # To migrate to declarative: replace `config = null` with a Nix attrset.
  services.home-assistant = {
    enable = true;
    package = unstablePkgs.home-assistant;
    config = null;
    extraComponents = [
      "default_config"
      "google_translate"
      "wyoming"
      "esphome"
      "roborock"
      "spotify"
      "simplisafe"
      "tado"
      "webostv"
      "shelly"
      "cast"
      "lg_thinq"
      "home_connect"

      "mobile_app"
      "met"
      "radio_browser"
    ];
    # Port 8123 is already opened in modules/hardware/intel.nix
  };

  # Wyoming Faster-Whisper (STT)
  services.wyoming.faster-whisper.servers."default" = {
    enable = true;
    language = "en";
    model = "distil-small.en";
    uri = "tcp://0.0.0.0:10300";
  };

  # Wyoming Piper (TTS)
  services.wyoming.piper.servers."default" = {
    enable = true;
    voice = "en_GB-alba-medium";
    uri = "tcp://0.0.0.0:10200";
  };
}
