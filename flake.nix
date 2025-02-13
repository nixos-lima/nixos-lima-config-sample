{
  description = "A sample NixOS-on-Lima configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    limainit.url = "github:nixos-lima/nixos-lima/master";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, limainit, home-manager, ... }@inputs:
    let
      # Change this to "x86_64-linux" if necessary
      system = "aarch64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
        nixosConfigurations.nixsample-aarch64 = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          # Pass the `limainit` input along with the default module system parameters
          specialArgs = { inherit limainit; };
          modules = [
            ./nixos-lima-config.nix
          ];
        };
        nixosConfigurations.nixsample-x86_64 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          # Pass the `limainit` input along with the default module system parameters
          specialArgs = { inherit limainit; };
          modules = [
            ./nixos-lima-config.nix
          ];
        };

        # You'll need to change the configuration name to match the username
        # that Lima automatically creates (same as your host username)
        homeConfigurations."lima" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            {
               home.username = "lima";
               home.homeDirectory = "/home/lima.linux";
               home.stateVersion = "25.05";
               programs.git.userEmail = "lima@nowaythisdomainexistsreally.com";
               programs.git.userName  = "Lima User";
            }
            ./home.nix
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    };    
}
