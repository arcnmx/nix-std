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
}
