{ config, pkgs, ... }:

{
  home.packages = [
    pkgs.hello
  ];
  # Git config will typically be placed in ~/.config/git/config
  programs.git = {
    enable = true;
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
    extraConfig = {
      safe = {
        directory = [ "/etc/nixos" ];
      };
    };
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

