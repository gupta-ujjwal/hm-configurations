{ pkgs, lib, ... }:

let
  version = "0.12.1";

  sources = {
    "aarch64-darwin" = {
      asset = "apm-darwin-arm64";
      sha256 = "b575dac3832f5b21cf34a370e795644cdc2c625520a0909808d927fb4700de4d";
    };
    "x86_64-darwin" = {
      asset = "apm-darwin-x86_64";
      sha256 = "bce72fd7d769fdd7f6117421f4bf6bc47711922a8fb69fbab228e034e3e69de0";
    };
    "aarch64-linux" = {
      asset = "apm-linux-arm64";
      sha256 = "364a651b8e383331cf0ae996d3d57b7f164b38de345634ae08fe7114c4f9e3a7";
    };
    "x86_64-linux" = {
      asset = "apm-linux-x86_64";
      sha256 = "a0b896e8cbdd10441125e989aa19d180c62052eda7c8aa850feb367805d1256f";
    };
  };

  system = pkgs.stdenv.hostPlatform.system;
  src = sources.${system} or (throw "apm: no prebuilt release for ${system}");

  apm = pkgs.stdenv.mkDerivation {
    pname = "apm";
    inherit version;

    src = pkgs.fetchurl {
      url = "https://github.com/microsoft/apm/releases/download/v${version}/${src.asset}.tar.gz";
      inherit (src) sha256;
    };

    nativeBuildInputs = lib.optionals pkgs.stdenv.isLinux [ pkgs.autoPatchelfHook ];
    buildInputs = lib.optionals pkgs.stdenv.isLinux [
      pkgs.stdenv.cc.cc.lib
      pkgs.zlib
      pkgs.openssl
    ];

    dontConfigure = true;
    dontBuild = true;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/libexec/apm $out/bin
      cp -R . $out/libexec/apm/
      ln -s $out/libexec/apm/apm $out/bin/apm
      runHook postInstall
    '';

    meta = with lib; {
      description = "APM (Agent Package Manager) — dependency manager for AI agents";
      homepage = "https://microsoft.github.io/apm/";
      license = licenses.mit;
      platforms = builtins.attrNames sources;
      mainProgram = "apm";
    };
  };
in
{
  home.packages = [ apm ];
}
