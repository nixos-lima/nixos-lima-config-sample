#!/bin/bash
# This script sets up a newly created Lima-NixOS guest by checking out
# both a NixOS system configuration from Git and rebuilding NixOS.
set -eux

# Name of NixOS default configuration to apply (from the repo's flake.nix)
DEFAULT_CONFIG_NAME='sample'
# Git Repo containing a flake.nix containing NixOS configurations
# In the sample the repo is the same as Home Manager repo, but they can be different
DEFAULT_CONFIG_REPO='https://github.com/nixos-lima/nixos-lima-config-sample.git'

display_help() {
    echo
    echo "Usage: $0 guest-hostname [guest-user] [config-name] [config-repo]"
    echo "Defaults are:"
    echo "guest-user: $USER"
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

# Name of main user in Guest OS, defaults to logged-in USER
GUEST_USER=${2:-$USER}
GUEST_HOME=/home/${GUEST_USER}.linux
GUEST_CONFIG_DIR=${GUEST_HOME}/.config

GUEST_CONFIG_NAME=${3:-$DEFAULT_CONFIG_NAME}
# NixOS configuration to use, if not provided use default
GUEST_CONFIG_REPO=${4:-$DEFAULT_CONFIG_REPO}

set +x
echo
echo Configuring \"$GUEST_HOST_NAME\" using \""$GUEST_CONFIG_REPO#$GUEST_CONFIG_NAME"\"  via user \"$GUEST_USER\"
echo
set -x

# Create ~/.config if it doesn't already exist
limactl shell $GUEST_HOST_NAME -- mkdir -p $GUEST_CONFIG_DIR

# Checkout $GUEST_CONFIG_REPO containing your NixOS host configuration flake
limactl shell $GUEST_HOST_NAME -- git clone --bare $GUEST_CONFIG_REPO $GUEST_CONFIG_DIR/nixos-config

# Setup NixOS system config in separate-git-dir owned by user, with working directory in /etc/nixos
limactl shell $GUEST_HOST_NAME -- sudo git init --separate-git-dir=$GUEST_CONFIG_DIR/nixos-config --shared=group /etc/nixos
limactl shell $GUEST_HOST_NAME -- sudo chown $GUEST_USER:wheel -R $GUEST_CONFIG_DIR/nixos-config
limactl shell $GUEST_HOST_NAME -- sudo bash -c "cd /etc/nixos ; git checkout master"
limactl shell $GUEST_HOST_NAME -- sudo nixos-rebuild boot --flake .#$GUEST_CONFIG_NAME
sleep 1
limactl restart $GUEST_HOST_NAME
