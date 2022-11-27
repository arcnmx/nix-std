with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  stored = nix.storeText "foo" "bar";
in section "std.nix" {
  try = string.unlines [
    (assertEqual optional.nothing (nix.try (throw "foo")))
    (assertEqual (optional.just "foo") (nix.try "foo"))
  ];
  storeText = assertEqual true (drv.isPath stored);
  getContext = string.unlines [
    (assertEqual {} (nix.getContext ""))
    (assertEqual true (nix.getContext stored != { }))
  ];
}
