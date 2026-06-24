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

set +x
if [ -n "${GITHUB_TOKEN:-}" ]; then
  # Copy GITHUB_TOKEN inside the VM to avoid GitHub API rate-limiting
  set +x
  printf 'access-tokens = github.com=%s\n' "$GITHUB_TOKEN" > nix.conf
  set -x
  chmod 600 nix.conf

  GUEST_HOME=$(limactl shell $GUEST_HOST_NAME -- bash -c 'echo $HOME')

  limactl shell $GUEST_HOST_NAME -- mkdir -p $GUEST_HOME/.config/nix
  limactl shell $GUEST_HOST_NAME -- sudo mkdir -p /root/.config/nix
  limactl copy nix.conf $GUEST_HOST_NAME:$GUEST_HOME/.config/nix/nix.conf
  rm nix.conf
  limactl shell $GUEST_HOST_NAME -- sudo cp $GUEST_HOME/.config/nix/nix.conf /root/.config/nix
  limactl shell $GUEST_HOST_NAME -- sudo chmod 600 $GUEST_HOME/.config/nix/nix.conf
  limactl shell $GUEST_HOST_NAME -- sudo chmod 600 /root/.config/nix/nix.conf
fi
set -x

# Checkout $GUEST_CONFIG_REPO containing your NixOS host configuration flake
limactl shell $GUEST_HOST_NAME -- sudo git clone $GUEST_CONFIG_REPO /etc/nixos
limactl shell $GUEST_HOST_NAME -- sudo nixos-rebuild boot --flake /etc/nixos#$GUEST_CONFIG_NAME
sleep 0.1
limactl restart $GUEST_HOST_NAME
