with { std = import ./../../default.nix; };
with std;

with (import ./../framework.nix);

let
  testFn = { a, b, c ? 1 }: a + b + c;
  testFunctor = {
    __functor = _: testFn;
  };
  testArgs = { a = 0; b = 1; };
  testOverrideFn = { a, b, c ? 1 }: { x = a + b + c; };
in section "std.function" {
  callable = string.unlines [
    (assertEqual 2 (testFn testArgs))
    (assertEqual 2 (testFunctor testArgs))
  ];
  show = string.unlines [
    (assertEqual "<<lambda>>" (types.function.show function.id))
    (assertEqual "{ a, b, c ? <<code>> }: <<code>>" (types.function.show testFn))
  ];
  check = string.unlines [
    (assertEqual true (types.function.check testFn))
    (assertEqual true (types.function.check testFunctor))
  ];
  args = string.unlines [
    (assertEqual { a = false; b = false; c = true; } (function.args testFn))
    (assertEqual { a = false; b = false; c = true; } (function.args testFunctor))
  ];
  setArgs = assertEqual { a = false; b = false; } (function.args (
    function.setArgs (set.without ["c"] (function.args testFn)) testFn
  ));
  isLambda = string.unlines [
    (assertEqual true (function.isLambda testFn))
    (assertEqual false (function.isLambda testFunctor))
  ];
  isFunctor = string.unlines [
    (assertEqual false (function.isFunctor testFn))
    (assertEqual true (function.isFunctor testFunctor))
  ];
  toFunctor = string.unlines [
    (assertEqual 2 (function.toFunctor testFn testArgs))
    (assertEqual 2 (function.toFunctor testFunctor testArgs))
    (assertEqual true (function.isFunctor (function.toFunctor testFn)))
  ];
  wrap = assertEqual 2 (function.wrap testFn testArgs);
  scopedArgs = string.unlines [
    (assertEqual testArgs (function.scopedArgs testArgs testFn))
    (assertEqual testArgs (function.scopedArgs (testArgs // { d = 1; }) testFn))
    (assertEqual (testArgs // { c = 2; }) (function.scopedArgs (testArgs // { c = 2; }) testFn))
  ];
  wrapScoped = string.unlines [
    (assertEqual 2 (function.wrapScoped set.empty testFn testArgs))
    (assertEqual 2 (function.wrapScoped testArgs testFn set.empty))
    (assertEqual 2 (function.wrapScoped { a = 1; } testFn testArgs))
    (assertEqual 3 (function.wrapScoped { a = 1; } testFn { inherit (testArgs) b; }))
    (assertEqual 3 (function.wrapScoped { c = 2; } testFn testArgs))
  ];
  overridable = string.unlines [
    (assertEqual 2 (function.overridable testOverrideFn testArgs).x)
    (assertEqual 2 ((function.overridable testOverrideFn testArgs).override { c = 1; }).x)
    (assertEqual 3 ((function.overridable testOverrideFn testArgs).override { a = 1; }).x)
    (assertEqual 3 (((function.overridable testOverrideFn testArgs).override { a = 2; }).override { a = 1; }).x)
    (assertEqual 3 (((function.overridable testOverrideFn testArgs).override { c = 1; }).override { a = 1; }).x)
    (assertEqual 2 (function.toFunctor testFunctor testArgs))
    (assertEqual true (function.isFunctor (function.toFunctor testFn)))
  ];
}
