with rec {
  function = import ./function.nix;
  inherit (function) id flip;

  bool = import ./bool.nix;
  list = import ./list.nix;
  optional = import ./optional.nix;
  path = import ./path.nix;
  set = import ./set.nix;
  string = import ./string.nix;
};

rec {
  /* storeDir :: string
  */
  storeDir = builtins.storeDir;

  /* storePath :: path
  */
  storePath = path.unsafeFromString storeDir;

  /* exists :: pathlike -> bool

     Relative paths (in the form of a string) are not supported,
     and will always return `false`.
  */
  exists = p:
    if builtins.isString p && ! string.hasPrefix "/" p then false
    else unsafeExists p;

  /* pathExists :: path -> bool

     Paths are always absolute, and thus safe to use.
  */
  pathExists = unsafeExists;

  /* unsafeExists :: pathlike -> bool
  */
  unsafeExists = builtins.pathExists;

  /* type :: pathlike -> optional type
  */
  type = {
    __functor = _: p: optional.match (path.from p) {
      inherit (optional) nothing;
      just = p: let
        name = path.baseName p;
        parent = path.parent p;
        ty = optional.fromNullable (builtins.readDir parent).${name} or null;
      in if name == "" then optional.just type.directory # root dir `/`
        else if pathExists parent then ty
        else optional.nothing;
    };
  } // flip set.gen id [
    # possible types:
    "regular"
    "directory"
    "symlink"
    "unknown"
  ];

  /* readFile :: pathlike -> optional string

     Returns `optional.nothing` if the path does not exist.
     See also: `readText`
  */
  readFile = p: bool.toOptional (exists p) (unsafeReadFile p);

  /* unsafeReadFile :: pathlike -> string
  */
  unsafeReadFile = builtins.readFile;

  /* readText :: pathlike -> optional string

     Reads a text file to a string, removing the trailing newline if it exists.
     Returns `optional.nothing` if the path does not exist.
  */
  readText = p: bool.toOptional (exists p) (unsafeReadText p);

  /* unsafeReadText :: pathlike -> string
  */
  unsafeReadText = p: string.removeSuffix "\n" (unsafeReadFile p);

  /* readDir :: pathlike -> optional dir

     Returns `optional.nothing` if the path does not exist.
  */
  readDir = p: bool.toOptional (type p == optional.just "directory") (unsafeReadDir p);

  /* unsafeReadDir :: pathlike -> dir
  */
  unsafeReadDir = p: set.map (basename: type: rec {
    path = p + "/${basename}";
    inherit basename type;
    exists = if type == "symlink" then unsafeExists path else true;
    children = bool.toOptional (type == "directory") (
      unsafeReadDir path
    );
  }) (builtins.readDir p);

  /* flattenDir :: dir -> [ file ]
  */
  flattenDir = dir: list.concat (set.mapToValues (_: file:
    list.singleton file
    ++ optional.match file.children {
      just = flattenDir;
      nothing = [ ];
    }
  ) dir);
}
