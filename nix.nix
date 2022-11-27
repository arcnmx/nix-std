with rec {
  function = import ./function.nix;
  inherit (function) flip;

  bool = import ./bool.nix;
  optional = import ./optional.nix;
  string = import ./string.nix;
};

rec {
  /* tupleToPair :: (string, a) -> nameValuePair

     Convert a key-value tuple to the type expected
     by `builtins.listToAttrs`
  */
  tupleToPair = { _0, _1 }: { name = _0; value = _1; };

  /* try :: a -> optional a

     Returns `optional.nothing` if `a` fails to evaluate.
  */
  try = x: let
    eval = builtins.tryEval x;
  in bool.toOptional eval.success eval.value;

  /* storeText :: string -> string -> pathlike

     Stores a string as a text file in the nix store under the
     specified file name, returning the resulting store path.
  */
  storeText = builtins.toFile;

  /* addContextFrom :: string -> string -> string

     Adds the context from one string to the other.
  */
  addContextFrom = context: str: string.substring 0 0 context + str;

  /* getContext :: string' -> set
  */
  getContext = builtins.getContext;

  /* setContext :: set -> string' -> set
  */
  setContext = cx: str: appendContext cx (removeContext str);

  /* removeContext :: string' -> string
  */
  removeContext = builtins.unsafeDiscardStringContext;

  /* appendContext :: set -> string' -> set
  */
  appendContext = flip builtins.appendContext;
}
