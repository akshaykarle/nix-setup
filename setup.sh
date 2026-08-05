#!/usr/bin/env bash

if command -v nix >/dev/null; then
  echo "nix is already installed on this system."
else
  curl -L https://nixos.org/nix/install | sh
  source /nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh
fi

# enable running flake
NIX_CONF_PATH="$HOME/.config/nix"
mkdir -p "$NIX_CONF_PATH"
if [[ ! -f $NIX_CONF_PATH/nix.conf ]] || ! grep "experimental-features" <"$NIX_CONF_PATH/nix.conf"; then
  echo "experimental-features = nix-command flakes" | tee -a "$NIX_CONF_PATH"/nix.conf
fi

# --- Corporate TLS cert bundle (EULONML17385 only) ---
# Convert any Root CA and Corporate .cer files to .pem using
# openssl x509 -inform DER -in "Corporate Root CA.cer" -out /tmp/corporate-root-ca.pem
# Then place the PEM files at
# ~/.config/corp-certs/ before running this script on the client machine.
# These files are NOT stored in the repo (public repo — no PKI details committed).
if uname -a | grep -q 'EULONML17385' && uname -a | grep -q 'arm64'; then
  CORP_CERT_DIR="$HOME/.config/corp-certs"
  if [ ! -d "$CORP_CERT_DIR" ] || [ -z "$(ls "$CORP_CERT_DIR"/*.pem 2>/dev/null)" ]; then
    echo "ERROR: Corporate CA certs not found at $CORP_CERT_DIR/*.pem" >&2
    echo "Place the Euromoney Root CA and Issuing CA01 PEM files there before running setup." >&2
    exit 1
  fi

  # Build stable bundle: system certs + corporate CAs (explicit newlines to avoid parse errors)
  sudo mkdir -p /etc/ssl/corp
  sudo bash -c '
    cat /etc/ssl/cert.pem > /etc/ssl/corp/nix-bundle.pem
    printf "\n" >> /etc/ssl/corp/nix-bundle.pem
  '
  for pem in "$CORP_CERT_DIR"/*.pem; do
    sudo bash -c "cat '$pem' >> /etc/ssl/corp/nix-bundle.pem && printf '\n' >> /etc/ssl/corp/nix-bundle.pem"
  done
  sudo chmod 644 /etc/ssl/corp/nix-bundle.pem

  # Configure Nix daemon to use the bundle (guard against duplicate entries on re-runs)
  if ! sudo grep -q 'ssl-cert-file' /etc/nix/nix.conf 2>/dev/null; then
    echo 'ssl-cert-file = /etc/ssl/corp/nix-bundle.pem' | sudo tee -a /etc/nix/nix.conf
  fi

  # Restart daemon so it picks up the new nix.conf
  sudo launchctl kickstart -k system/org.nixos.nix-daemon
  sleep 2

  # Also set for this shell session
  export NIX_SSL_CERT_FILE=/etc/ssl/corp/nix-bundle.pem
fi
# --- End corporate TLS cert bundle ---

# link current dir into nixpkgs
ln -sf $(pwd) $HOME/.config/nixpkgs

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-26.05.tar.gz home-manager
nix-channel --update

NIX_CMD="${1:-switch}"

if [ -n "$(uname -a | grep 'EULONML17385' | grep 'arm64')" ]; then
  which brew >/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- $NIX_CMD --flake '.#akshay.karle@aarch64-darwin'
elif [ -n "$(uname -a | grep 'Darwin' | grep 'x86_64')" ]; then
  which brew >/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- $NIX_CMD --flake '.#akshaykarle@x86_64-darwin'
elif [ -n "$(uname -a | grep 'Darwin' | grep 'arm64')" ]; then
  which brew >/dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  sudo nix run --extra-experimental-features nix-command --extra-experimental-features flakes nix-darwin -- $NIX_CMD --flake '.#akshaykarle@aarch64-darwin'
elif [ -n "$(whoami | grep 'daksh-home')" ]; then
  sudo nixos-rebuild $NIX_CMD --flake .#"daksh-home@x86_64-linux"
else
  sudo nixos-rebuild $NIX_CMD --flake .#"akshaykarle@x86_64-linux"
fi
