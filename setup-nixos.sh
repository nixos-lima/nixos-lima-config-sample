#!/bin/bash
# This script sets up a newly created Lima-NixOS guest by checking out
# both a NixOS system configuration from Git and rebuilding NixOS.
set -eux

# Name of NixOS default configuration to apply (from the repo's flake.nix)
DEFAULT_CONFIG_NAME='nixsample'
# Git Repo containing a flake.nix containing NixOS configurations
# In the sample the repo is the same as Home Manager repo, but they can be different
DEFAULT_CONFIG_REPO='https://github.com/nixos-lima/nixos-lima-config-sample.git'

display_help() {
    echo
    echo "Usage: $0 guest-hostname [config-name] [config-repo]"
    echo "Defaults are:"
    echo "config-name: $DEFAULT_CONFIG_NAME"
    echo "config-repo: $DEFAULT_CONFIG_REPO"
    echo
}

# Check if no arguments are provided
set +x
if [ $# -eq 0 ]; then
    display_help
    exit 1
fi
set -x

# Name of Lima VM (Guest Host), required parameter
GUEST_HOST_NAME=${1}

GUEST_CONFIG_NAME=${2:-$DEFAULT_CONFIG_NAME}
# NixOS configuration to use, if not provided use default
GUEST_CONFIG_REPO=${3:-$DEFAULT_CONFIG_REPO}

set +x
echo
echo Configuring \"$GUEST_HOST_NAME\" using \""$GUEST_CONFIG_REPO#$GUEST_CONFIG_NAME"\"
echo
set -x


# Checkout $GUEST_CONFIG_REPO containing your NixOS host configuration flake
limactl shell $GUEST_HOST_NAME -- sudo git clone $GUEST_CONFIG_REPO /etc/nixos
limactl shell $GUEST_HOST_NAME -- sudo nixos-rebuild boot --flake /etc/nixos#$GUEST_CONFIG_NAME
sleep 0.1
limactl stop $GUEST_HOST_NAME
limactl start $GUEST_HOST_NAME
