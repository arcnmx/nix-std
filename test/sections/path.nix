with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  testDrv = builtins.derivation {
    name = "test";
    builder = "test";
    system = "x86_64-linux";
  };
in section "std.path" {
  check = string.unlines [
    (assertEqual true (types.path.check ./path.nix))
    (assertEqual false (types.path.check (toString ./path.nix)))
    (assertEqual true (types.pathlike.check ./path.nix))
    (assertEqual true (types.pathlike.check testDrv))
    (assertEqual true (types.pathlike.check (toString ./path.nix)))
    (assertEqual false (types.pathlike.check "a/b/c"))
  ];

  baseName = string.unlines [
    (assertEqual "path.nix" (path.baseName ./path.nix))
    (assertEqual "path.nix" (path.baseName (toString ./path.nix)))
    (assertEqual "-test" (string.substring 32 (-1) (path.baseName testDrv)))
  ];

  dirName = string.unlines [
    (assertEqual ./. (path.parent ./path.nix))
    (assertEqual (toString ./.) (path.dirName (toString ./path.nix)))
    (assertEqual (toString builtins.storeDir) (path.dirName testDrv))
  ];

  fromString = string.unlines [
    (assertEqual (optional.just /a/b/c) (path.fromString "/a/b/c"))
    (assertEqual optional.nothing (path.fromString "a/b/c"))
  ];
}
