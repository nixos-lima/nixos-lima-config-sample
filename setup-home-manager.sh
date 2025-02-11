#!/bin/bash
#
# This script sets up Home Manager in newly created Lima-NixOS guest by checking out
# a Home Manager configuration from a Git repo and initializing Home Manager.
set -eux

# Git Repo containing a flake.nix containing Home Manager configurations
# In the sample the repo is the same as the NixOS configuration repo, but they can be different
DEFAULT_CONFIG_REPO='https://github.com/nixos-lima/nixos-lima-config-sample.git'

display_help() {
    echo
    echo "Usage: $0 guest-hostname [guest-user] [config-repo]"
    echo "Defaults are:"
    echo "guest-user: $USER"
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

# Name of main user in Guest OS, defaults to logged-in USER
GUEST_USER=${2:-$USER}
GUEST_HOME=/home/${GUEST_USER}.linux
GUEST_CONFIG_DIR=${GUEST_HOME}/.config

# Home Manager configuration to use, if not provided use default
GUEST_CONFIG_REPO=${4:-$DEFAULT_CONFIG_REPO}

set +x
echo
echo Configuring \"${GUEST_USER}@${GUEST_HOST_NAME}\" using \""$GUEST_CONFIG_REPO#$GUEST_USER"\"
echo
set -x

# Create ~/.config if it doesn't already exist
limactl shell $GUEST_HOST_NAME -- mkdir -p $GUEST_CONFIG_DIR

# Checkout $GUEST_CONFIG_REPO containing your Home Manager configuration flake
limactl shell $GUEST_HOST_NAME -- git clone $GUEST_CONFIG_REPO $GUEST_CONFIG_DIR/home-manager

# Configure subuid/subgid support for running rootless Podman services
#limactl shell $GUEST_HOST_NAME -- sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $LIMA_USER

# Initialize Home Manager
limactl shell $GUEST_HOST_NAME -- nix run home-manager/master -- init --switch

