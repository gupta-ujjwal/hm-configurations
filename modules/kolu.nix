{ config, pkgs, lib, kolu, system, ... }:

{
  imports = [ kolu.homeManagerModules.default ];

  services.kolu = {
    enable = true;
    package = kolu.packages.${system}.default;
    host = "0.0.0.0";
    port = 7681;
  };
}
