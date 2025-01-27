#!/bin/bash
#
# This script sets up a newly created Lima-NixOS guest by checking out
# both a Home Manager configuration and a NixOS system configuration from Git
# and initializing Home Manager and rebuilding NixOS.
#
set -eux

LIMA_NAME=nixsample
LIMA_USER=${1:-$USER}
LIMA_HOME=/home/${LIMA_USER}.linux
CONFIG_DIR=$LIMA_HOME/.config

# In the sample this is the same as Home Manager repo, but they can be different
NIXOS_CONFIG_REPO=https://github.com/nixos-lima/nixos-lima-config-sample.git

# Create ~/.config if it doesn't already exist
limactl shell $LIMA_NAME -- mkdir -p $CONFIG_DIR

# Checkout NIXOS_CONFIG_REPO containing your NixOS host configuration flake
limactl shell $LIMA_NAME -- git clone --bare $NIXOS_CONFIG_REPO $CONFIG_DIR/nixos-config

# Setup NixOS system config in separate-git-dir owned by user, with working directory in /etc/nixos
limactl shell $LIMA_NAME -- sudo git init --separate-git-dir=$CONFIG_DIR/nixos-config --shared=group /etc/nixos
limactl shell $LIMA_NAME -- sudo chown $LIMA_USER:wheel -R $CONFIG_DIR/nixos-config
limactl shell $LIMA_NAME -- sudo bash -c "cd /etc/nixos ; git checkout master"
limactl shell $LIMA_NAME -- sudo nixos-rebuild switch --flake .#sample

