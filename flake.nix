{
  description = "A sample NixOS-on-Lima configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    limainit.url = "github:msgilligan/nixos-lima/msgilligan-main";
  };

  outputs = { self, nixpkgs, limainit, ... }@inputs: {
    nixosConfigurations.sample = nixpkgs.lib.nixosSystem {
      # Change this to "x86_64-linux" if necessary
      system = "aarch64-linux";
      # Pass the `limainit` input along with the default module system parameters
      specialArgs = { inherit limainit; };
      modules = [
        ./nixos-lima-config.nix
      ];
    };
  };
}
