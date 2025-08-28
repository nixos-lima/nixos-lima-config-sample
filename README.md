# nixos-lima-config-sample

A sample NixOS configuration flake that uses the [nixos-lima](https://github.com/nixos-lima/nixos-lima) module to enable running NixOS within a [Lima](https://lima-vm.io)-managed VM on macOS.

This repository can be used as a template for your custom NixOS Lima VM configuration. Because it references the `nixos-lima` module, you should be able to update to new and improved versions while maintaining the configuration of your VM separately/privately.
   
 The sample BASH scripts `setup-nixos.sh` and `setup-home-manager.sh` are used to check out Git repositories for Home Manager and NixOS system configuration, respectively and to build/switch to that configuration. These mechanisms allow you to configure and manage a NixOS Lima VM and track changes in a Git repository. Note that it is possible to use a single repository for both the Home Manager and the NixOS configuration.

This example uses the latest base image release from [nixos-lima](https://github.com/nixos-lima/nixos-lima).

## Prerequisites

* macOS 13.5+ or recent Linux with Lima installed

NOTE: Nix is not needed to run a NixOS Lima VM (e.g. you can install Lima with Homebrew or another mechanism)

## Installation

Check out this repository to your Lima host. The following commands can be used with no customization of this repository. (The main username for the guest VM, "lima" is hardcoded in `flake.nix`.)

```
limactl start --yes --set '.user.name = "lima"' nixos.yaml
./setup-nixos.sh nixos lima nixsample-aarch64
./setup-home-manager.sh nixos lima
```

If you create a fork or copy of this repo, or use your own Home Manager flake, you would likely use the same username as you use on the host system, so in that case the commands would be simpler:                             

```
limactl start --yes nixos.yaml
./setup-nixos.sh nixos $USER nixsample-aarch64
./setup-home-manager.sh nixos $USER
```
You can then log in to your NixOS guest VM using:

```
limactl shell nixos
```

## Help Wanted

Feedback, issues, and pull-requests are all most welcome.
