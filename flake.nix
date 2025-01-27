{
  description = "A sample NixOS-on-Lima configuration flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    limainit.url = "github:msgilligan/nixos-lima/msgilligan-main";
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
        nixosConfigurations.sample = nixpkgs.lib.nixosSystem {
          inherit system;
          # Pass the `limainit` input along with the default module system parameters
          specialArgs = { inherit limainit; };
          modules = [
            ./nixos-lima-config.nix
          ];
        };
        # You'll need to change the configuration name to match the username
        # that Lima automatically creates (same as your host username)
        homeConfigurations."runner" = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [
            {
               home.username = "runner";
               home.homeDirectory = "/home/runner.linux";
               home.stateVersion = "25.05";
               programs.git.userEmail = "runner@github.com";
               programs.git.userName  = "GitHub Runner";
            }
            ./home.nix
          ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
        };
    };    
}
