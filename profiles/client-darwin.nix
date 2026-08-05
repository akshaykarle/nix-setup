{ config, ... }:
{
  networking.hostName = "EULONML17385";

  user.name = "akshay.karle";
  user.description = "Karle, Akshay (UK)";

  # User was provisioned externally (corporate directory service).
  # Override the default UID of 501 set in modules/darwin/core.nix to
  # match the actual UID assigned by the corporate IdP.
  user.uid = 1638495395;

  hm.claude.profiles = [ "client" ];
  hm.pi.profiles = [ "client" ];

  # Belt-and-suspenders: set http.sslCAInfo in git config so tools like the
  # neovim plugin manager that spawn git as a subprocess pick up the corporate
  # CA bundle even when GIT_SSL_CAINFO is not inherited from the environment.
  # Do NOT set http.sslVerify = false — that would disable SSL verification.
  hm.programs.git = {
    enable = true;
    extraConfig = {
      http.sslCAInfo = "/etc/ssl/corp/nix-bundle.pem";
    };
  };

  # Rebuild corporate TLS cert bundle from certs in ~/.config/corp-certs/.
  # Certs are NOT stored in the repo — place them manually on the machine.
  # Without this, nix commands fail with curl error 60/77 / OpenSSL error 19.
  system.activationScripts.nixCertBundle.text = ''
    CORP_CERT_DIR="/Users/${config.user.name}/.config/corp-certs"
    if [ -d "$CORP_CERT_DIR" ] && ls "$CORP_CERT_DIR"/*.pem >/dev/null 2>&1; then
      mkdir -p /etc/ssl/corp
      cat /etc/ssl/cert.pem > /etc/ssl/corp/nix-bundle.pem
      printf "\n" >> /etc/ssl/corp/nix-bundle.pem
      for pem in "$CORP_CERT_DIR"/*.pem; do
        cat "$pem" >> /etc/ssl/corp/nix-bundle.pem
        printf "\n" >> /etc/ssl/corp/nix-bundle.pem
      done
      chmod 644 /etc/ssl/corp/nix-bundle.pem
    fi
  '';

  nix.settings.ssl-cert-file = "/etc/ssl/corp/nix-bundle.pem";

  environment.variables = {
    NIX_SSL_CERT_FILE = "/etc/ssl/corp/nix-bundle.pem"; # nix CLI
    GIT_SSL_CAINFO = "/etc/ssl/corp/nix-bundle.pem"; # git (nixpkgs git uses OpenSSL, not keychain)
    SSL_CERT_FILE = "/etc/ssl/corp/nix-bundle.pem"; # Python requests, Ruby, misc OpenSSL tools
    CURL_CA_BUNDLE = "/etc/ssl/corp/nix-bundle.pem"; # curl outside of nix context
  };
}
