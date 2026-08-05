{ config, ... }:
{
  networking.hostName = "EULONML17385";

  user.name = "akshay.karle";
  user.description = "Karle, Akshay (UK)";

  hm.claude.profiles = [ "client" ];
  hm.pi.profiles = [ "client" ];

  # Build a combined TLS cert bundle: system certs + any extra CAs in the login keychain.
  # Without this, nix commands fail with curl error 60 / OpenSSL error 19.
  system.activationScripts.nixCertBundle.text = ''
    _bundle=/etc/ssl/nix-cert-bundle.pem
    cat /etc/ssl/cert.pem > "$_bundle"
    /usr/bin/security export \
      -k "/Users/${config.user.name}/Library/Keychains/login.keychain-db" \
      -t certs -f pemseq 2>/dev/null >> "$_bundle" || true
    chmod 644 "$_bundle"
  '';

  nix.settings.ssl-cert-file = "/etc/ssl/nix-cert-bundle.pem";

  environment.variables.NIX_SSL_CERT_FILE = "/etc/ssl/nix-cert-bundle.pem";
}
