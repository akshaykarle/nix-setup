#!/usr/bin/env bash

if command -v nix >/dev/null; then
    echo "nix is already installed on this system."
else
    curl -L https://nixos.org/nix/install | sh
    source ~/.nix-profile/etc/profile.d/nix.sh
fi

# enable running flake
NIX_CONF_PATH="$HOME/.config/nix"
mkdir -p "$NIX_CONF_PATH"
if [[ ! -f $NIX_CONF_PATH/nix.conf ]] || ! grep "experimental-features" <"$NIX_CONF_PATH/nix.conf"; then
    echo "experimental-features = nix-command flakes" | tee -a "$NIX_CONF_PATH"/nix.conf
fi

# link current dir into nixpkgs
ln -sf $(pwd) $HOME/.config/nixpkgs

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-23.11.tar.gz home-manager
nix-channel --update

if [ -n "$(uname | grep 'Darwin')" ]
then
    nix run nix-darwin -- switch --flake  '.#akshaykarle@x86_64-darwin'
else
    sudo nixos-rebuild switch --flake '.#akshaykarle@x86_64-linux'
fi
