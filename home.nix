{ config, pkgs, ... }:

{
  home = {
    username = "Ujjwal.gupta";
    homeDirectory = "/Users/Ujjwal.gupta";
    stateVersion = "22.11";
  };

  programs.home-manager = {
    enable = true;
  };

  home.packages = with pkgs; 
 	[  haskellPackages.hoogle mysql htop btop git stack redis tmux];
}
