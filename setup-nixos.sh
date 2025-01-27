#!/bin/bash
#
# This script sets up a newly created Lima-NixOS guest by checking out
# both a Home Manager configuration and a NixOS system configuration from Git
# and initializing Home Manager and rebuilding NixOS.
#
set -eux

LIMA_NAME=nixsample
LIMA_USER=lima
LIMA_HOME=/home/${LIMA_USER}.linux
CONFIG_DIR=$LIMA_HOME/.config

# In the sample these are the same repo, but they can be different
HOME_CONFIG_REPO=https://github.com/nixos-lima/nixos-lima-config-sample.git
NIXOS_CONFIG_REPO=https://github.com/nixos-lima/nixos-lima-config-sample.git 

# Create ~/.config if it doesn't already exist
limactl shell $LIMA_NAME -- mkdir -p $CONFIG_DIR

# Checkout HOME_CONFIG_REPO containing your Home Manager configuration flake
limactl shell $LIMA_NAME -- git clone $HOME_CONFIG_REPO $CONFIG_DIR/home-manager 

# Checkout NIXOS_CONFIG_REPO containing your NixOS host configuration flake
limactl shell $LIMA_NAME -- git clone --bare $NIXOS_CONFIG_REPO $CONFIG_DIR/nixos-config

# Initialize Home Manager
limactl shell $LIMA_NAME -- nix run home-manager/master -- init --switch

# Setup NixOS system config in separate-git-dir owned by user, with working directory in /etc/nixos
limactl shell $LIMA_NAME -- sudo git init --separate-git-dir=$CONFIG_DIR/nixos-config --shared=group /etc/nixos
limactl shell $LIMA_NAME -- sudo chown $LIMA_USER:wheel -R $CONFIG_DIR/nixos-config
limactl shell $LIMA_NAME -- sudo bash -c "cd /etc/nixos ; git checkout master"
limactl shell $LIMA_NAME -- sudo nixos-rebuild switch --flake .#sample

# Configure subuid/subgid support for running rootless Podman services
limactl shell $LIMA_NAME -- sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $LIMA_USER

