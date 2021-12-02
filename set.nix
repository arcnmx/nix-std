with rec {
  function = import ./function.nix;
  inherit (function) id flip;
  list = import ./list.nix;
};

rec {
  semigroup = {
    append = x: y: x // y;
  };

  monoid = semigroup // {
    inherit empty;
  };

  /* empty :: set
  */
  empty = {};

  /* assign :: key -> value -> set -> set
  */
  assign = k: v: r: r // { "${k}" = v; };

  match = o: { empty, assign }:
    if o == {}
    then empty
    else match1 o { inherit assign; };

  # O(log(keys))
  match1 = o: { assign }:
    let k = list.head (keys o);
        v = o."${k}";
        r = builtins.removeAttrs o [k];
    in assign k v r;

  /* keys :: set -> [key]
  */
  keys = builtins.attrNames;

  /* values :: set -> [value]
  */
  values = builtins.attrValues;

  /* map :: (key -> value -> value) -> set -> set
  */
  map = builtins.mapAttrs;

  /* filter :: (key -> value -> bool) -> set -> set
  */
  filter = f: s: builtins.listToAttrs (list.concatMap (name: let
    value = s.${name};
  in list.optional (f name value) { inherit name value; }) (keys s));

  /* without :: [key] -> set -> set
  */
  without = flip builtins.removeAttrs;

  /* retain :: [key] -> set -> set
  */
  retain = keys: builtins.intersectAttrs (gen keys id);

  /* traverse :: Applicative f => (value -> f
  */
  traverse = ap: f:
    (flip match) {
      empty = ap.pure empty;
      assign = k: v: r: ap.lift2 id (ap.map (assign k) (f v)) (traverse ap f r);
    };

  /* toList :: set -> [(key, value)]
  */
  toList = s: list.map (k: { _0 = k; _1 = s.${k}; }) (keys s);

  /* fromList :: [(key, value)] -> set
  */
  fromList = xs: builtins.listToAttrs (list.map ({ _0, _1 }: { name = _0; value = _1; }) xs);

  /* gen :: [key] -> (key -> value) -> set
  */
  gen = keys: f: fromList (list.map (n: { _0 = n; _1 = f n; }) keys);
}
