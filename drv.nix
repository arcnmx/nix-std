with rec {
  function = import ./function.nix;
  inherit (function) flip;

  bool = import ./bool.nix;
  fs = import ./fs.nix;
  list = import ./list.nix;
  optional = import ./optional.nix;
  path = import ./path.nix;
  string = import ./string.nix;
  types = import ./types.nix;
};

rec {
  isPath = p: string.hasPrefix fs.storeDir p;

  nameWithPath = p:
    string.substring 33 (-1) (path.baseName p);

  nameOf = d:
    if types.drv.check d then optional.just d.name
    else if isPath d then optional.just (nameWithPath d)
    else optional.nothing;

  parsedNameOf = d: optional.functor.map builtins.parseDrvName (nameOf d);

  # program name as defined by `nix run`
  mainProgramName = d: d.meta.mainProgram or d.pname or (parsedNameOf d).value.name;

  # absolute path to a derivation's `mainProgramName`
  mainProgram = d: "${d.bin or d}/bin/${mainProgramName d}";

  appendPassthru = passthru: d: d // passthru; # TODO: nixpkgs.lib.extendDerivation also modifies outputs

  # derivations that can reference their own (potentially overridden) attributes
  fix = fn: let
    drv = fn drv;
    passthru = {
      ${bool.toNullable (drv ? override) "override"} = f: fix (drv: (fn drv).override f);
      ${bool.toNullable (drv ? overrideDerivation) "overrideDerivation"} = f: fix (drv: (fn drv).overrideDerivation f);
      ${bool.toNullable (drv ? overrideAttrs) "overrideAttrs"} = f: fix (drv: (fn drv).overrideAttrs f);
    };
  in appendPassthru passthru drv;

  # add persistent passthru attributes that can refer to the derivation
  fixPassthru = fn: drv: if types.function.check drv # allow chaining with mkDerivation
    then attrs: fixPassthru fn (drv attrs)
    else fix (dself: drv.overrideAttrs (old: { passthru = old.passthru or {} // fn dself; }));
}
