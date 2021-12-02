with rec {
  set = import ./set.nix;
  types = import ./types.nix;
};

rec {
  /* id :: a -> a
  */
  id = x: x;

  /* const :: a -> b -> a
  */
  const = a: _: a;

  /* compose :: (b -> c) -> (a -> b) -> (a -> c)
  */
  compose = bc: ab: a: bc (ab a);

  /* flip :: (a -> b -> c) -> b -> a -> c
  */
  flip = f: b: a: f a b;

  /* args :: f -> set
  */
  args = f:
    if f ? __functor then f.__functionArgs or (args (f.__functor f))
    else builtins.functionArgs f;

  /* setArgs :: set -> f -> f
  */
  setArgs = args: f: set.assign "__functionArgs" args (toSet f);

  /* copyArgs :: fa -> fb -> fb
  */
  copyArgs = src: dst: setArgs (args src) dst;

  /* toSet :: f -> set

     Convert a lambda into a callable set, unless `f` already is one.

     > function.toSet function.id // { foo = "bar"; }
     { __functor = «lambda»; foo = "bar"; }
  */
  toSet = f: if types.lambda.check f then {
    __functor = self: f;
  } else f;
}
