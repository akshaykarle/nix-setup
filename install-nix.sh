#!/usr/bin/env bash
set -x

if command -v nix >/dev/null; then
    echo "nix is already installed on this system."
else
    curl -L https://nixos.org/nix/install | sh
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

NIX_CONF_PATH="$HOME/.config/nix"
mkdir -p "$NIX_CONF_PATH"
if [[ ! -f $NIX_CONF_PATH/nix.conf ]] || ! grep "experimental-features" <"$NIX_CONF_PATH/nix.conf"; then
    echo "experimental-features = nix-command flakes" | tee -a "$NIX_CONF_PATH"/nix.conf
fi
