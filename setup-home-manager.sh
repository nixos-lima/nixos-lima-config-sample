#!/bin/bash
#
# This script sets up Home Manager in newly created Lima-NixOS guest by checking out
# a Home Manager configuration from a Git repo and initializing Home Manager.
#
# If parameter $1 is specified it will be used as the main username within the instance,
# otherwise it will be set to $USER.
#
set -eux

LIMA_NAME=nixsample
LIMA_USER=${1:-$USER}
LIMA_HOME=/home/${LIMA_USER}.linux
CONFIG_DIR=$LIMA_HOME/.config

HOME_CONFIG_REPO=https://github.com/nixos-lima/nixos-lima-config-sample.git

# Create ~/.config if it doesn't already exist
limactl shell $LIMA_NAME -- mkdir -p $CONFIG_DIR

# Checkout HOME_CONFIG_REPO containing your Home Manager configuration flake
limactl shell $LIMA_NAME -- git clone $HOME_CONFIG_REPO $CONFIG_DIR/home-manager

# Initialize Home Manager
limactl shell $LIMA_NAME -- nix run home-manager/master -- init --switch

# Configure subuid/subgid support for running rootless Podman services
limactl shell $LIMA_NAME -- sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $LIMA_USER

