# nixos-lima-config-sample

A sample NixOS configuration flake that uses the [nixos-lima](https://github.com/nixos-lima/nixos-lima) module (currently at `github:nixos-lima/nixos-lima/master`) to enable running NixOS within a [Lima](https://lima-vm.io) managed VM on macOS.

This repository is meant to be used as a template for your custom NixOS Lima VM configuration. Because it references the `nixos-lima` module, you should be able to update to new and improved versions while maintaining the configuration of your VM separately/privately.

## Installation

See the instructions in the [nixos-lima README](https://github.com/nixos-lima/nixos-lima?tab=readme-ov-file#generating-the-image) for creating a Lima NixOS VM. Follow the instructions there for "Generating the image" and "Running NixOS", but for the "Rebuilding NixOS inside the Lima instance" use the flake in this repository.

You should even be able to clone this repository and version control your changes with Git.

## Help Wanted

Feedback, issues, and pull-requests are all most welcome.