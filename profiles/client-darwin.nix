{ config, ... }:
{
  networking.hostName = "EULONML17385";

  user.name = "akshay.karle";
  user.description = "Karle, Akshay (UK)";

  hm.claude.profiles = [ "client" ];
  hm.pi.profiles = [ "client" ];

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

  environment.variables.NIX_SSL_CERT_FILE = "/etc/ssl/corp/nix-bundle.pem";
}
