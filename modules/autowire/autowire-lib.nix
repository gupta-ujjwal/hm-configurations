# Vendored from srid/nix-agent-wire @ 69e550ac2a922b72f781c165d68a3f549582dc45
# (nix/autowire-lib.nix). MIT License, Copyright (c) 2025 Sridhar Ratnakumar.
# Patched: readSkills returns path values (not toString'd strings) so skill dirs are real store inputs.
{ lib }:

{
  mergeAttrsList = lib.foldl' lib.mergeAttrs { };

  readCommands = dir:
    let path = toString dir + "/commands";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readSkills = dir:
    let path = toString dir + "/skills";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (skillName: _:
          lib.nameValuePair
            skillName
            (/. + (path + "/" + skillName))
        )
        (lib.filterAttrs (_: type: type == "directory") (builtins.readDir path)));

  readAgentsContent = dir:
    let path = toString dir + "/agents";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readAgentsPath = dir:
    let path = toString dir + "/agents";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".md" fileName)
            (builtins.readFile (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readMcpServers = dir:
    let path = toString dir + "/mcp";
    in lib.optionalAttrs (builtins.pathExists path)
      (lib.mapAttrs'
        (fileName: _:
          lib.nameValuePair
            (lib.removeSuffix ".nix" fileName)
            (import (path + "/${fileName}"))
        )
        (builtins.readDir path));

  readMemoryAttrset = dir:
    let path = toString dir + "/memory.md";
    in lib.optionalAttrs (builtins.pathExists path)
      { text = builtins.readFile path; };

  readMemoryString = dir:
    let path = toString dir + "/memory.md";
    in lib.optionalString (builtins.pathExists path)
      (builtins.readFile path);

  readSettings = name: dir:
    let path = toString dir + "/settings/${name}.nix";
    in lib.optionalAttrs (builtins.pathExists path)
      (import path);
}
