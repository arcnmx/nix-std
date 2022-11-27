with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  dir = fs.unsafeReadDir ./.fs;
in section "std.fs" {
  exists = string.unlines [
    (assertEqual true (fs.exists ./.))
    (assertEqual true (fs.exists (toString ./.)))
    (assertEqual true (fs.exists ./fs.nix))
    (assertEqual true (fs.exists ./.fs/test.symlink))
    (assertEqual false (fs.exists ./.fs/broken.symlink))
  ];
  type = string.unlines [
    (assertEqual (optional.just fs.type.directory) (fs.type /.))
    (assertEqual (optional.just fs.type.directory) (fs.type (toString /.)))
    (assertEqual (optional.just fs.type.directory) (fs.type "//"))
    (assertEqual (optional.just fs.type.directory) (fs.type "/./"))
    (assertEqual (optional.just fs.type.directory) (fs.type ./.))
    (assertEqual (optional.just fs.type.directory) (fs.type (toString ./.)))
    (assertEqual (optional.just fs.type.regular) (fs.type ./fs.nix))
    (assertEqual (optional.just fs.type.symlink) (fs.type ./.fs/test.symlink))
    (assertEqual (optional.just fs.type.symlink) (fs.type ./.fs/broken.symlink))
    (assertEqual optional.nothing (fs.type ./.fs/dummy))
  ];
  read = string.unlines [
    (assertEqual (optional.just "foo\n") (fs.readFile ./.fs/test.txt))
    (assertEqual (optional.just "foo\n") (fs.readFile (toString ./.fs/test.txt)))
    (assertEqual (optional.just "foo") (fs.readText ./.fs/test.txt))
  ];
  readDir = string.unlines [
    (assertEqual true (optional.isJust (fs.readDir ./.fs)))
    (assertEqual ./.fs/test.txt dir."test.txt".path or null)
    (assertEqual fs.type.directory dir.dir.type or null)
    (assertEqual true (optional.isJust dir.dir.children or optional.nothing))
    (assertEqual "test.file" dir.dir.children.value."test.file".basename or null)
    (assertEqual ./.fs/dir/test.file dir.dir.children.value."test.file".path or null)
  ];
  flattenDir = assertEqual [
    dir."broken.symlink" or null
    dir.dir or null
    dir.dir.children.value."test.file" or null
    dir."test.symlink" or null
    dir."test.txt" or null
  ] (fs.flattenDir dir);
}
