{ config, pkgs, ... }:
{
  home.packages = [
    pkgs.hello
  ];
  # Git config will typically be placed in ~/.config/git/config
  programs.git = {
    enable = true;
    package = pkgs.gitMinimal;  # Minimal Git without Perl or Python
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}

