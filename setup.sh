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

# link current dir into nixpkgs
ln -sf $(pwd) $HOME/.config/nixpkgs

# install home-manager
nix-channel --add https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz home-manager
nix-channel --update

NIX_CMD="${1:-switch}"

if [ -n "$(uname | grep 'Darwin')" ]
then
    which brew > /dev/null || bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    nix run nix-darwin -- $NIX_CMD --flake  '.#akshaykarle@x86_64-darwin'
else
    sudo nixos-rebuild $NIX_CMD --flake .#"akshaykarle@x86_64-linux"
fi
