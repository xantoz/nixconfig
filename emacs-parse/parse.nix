{ pkgs, lib }:

rec {
  inherit (import ./fromElisp { inherit pkgs; }) fromElisp;

  # Invoking Greenspuns 10th rule :^)
  # Note: Lisp car & cdr always return the empty list when passed the empty list, but builtins.head and builtilns.tail does not do this
  car = lst: if lst == [] then [] else builtins.head lst;
  cdr = lst: if lst == [] then [] else builtins.tail lst;
  cadr = lst: (car (cdr lst));
  cddr = lst: (cdr (cdr lst));
  cdar = lst: (cdr (car lst));
  caar = lst: (car (car lst));

  keywordp = symbol: ((builtins.isString symbol) && (lib.hasPrefix ":" symbol));

  listUntil = predicate: lst:
    if lst == [] then
      []
    else if (predicate (car lst)) then
      []
    else
      [(car lst)] ++ (listUntil predicate (cdr lst)); # Imagine that this is a cons for an imaginary speed benefit

  memq = keyword: lst:
    if lst == [] then
      []
    else
      if (car lst) == keyword then
        lst
      else
        memq keyword (cdr lst);

  getParameter = keyword: body:
    let
      lst = memq keyword body;
    in
      if lst == [] then
        []
      else
        [(car lst)] ++ (listUntil keywordp (cdr lst));

  handleUsePackage = expr:
    if (memq ":disabled" (cddr expr)) != [] then
      []
    else
      let
        name = (cadr expr);
        body = (cddr expr);
        ensure = (getParameter ":ensure" body);
        packageName =
          if ensure == [ ":ensure" true ]
             || ensure == [ ":ensure" "t" ]
             || ensure == [ ":ensure" ] then
            [ name ]
          else if ensure == [ ":ensure" [] ] then
            []
          else
            (cdr ensure);
        initProgn = (cdr (getParameter ":init" body));
        configProgn = (cdr (getParameter ":config" body));
        prefaceProgn = (cdr (getParameter ":preface" body));
      in
        packageName ++ (walk initProgn) ++ (walk configProgn) ++ (walk prefaceProgn);

  walk = tree:
    if !(builtins.isList tree) || (tree == []) then
      []
    else if (car tree) == "when" && (cadr tree) == [] then # Ignore parts commented out with (when nil ...)
      []
    else if (car tree) == "unless" && (cadr tree) != [] then # Ignore parts commented out with (unless t ...) or similar
      []
    else if (car tree) == "use-package" then
      handleUsePackage tree
    else
      (walk (car tree)) ++ (walk (cdr tree));

  parsePackagesFromUsePackage = configText:
    (walk (fromElisp configText));

  usePackagePkgs = with builtins; {
    config,
    override ? (epkgs: epkgs),
    extraPackages ? []
  }:
  (epkgs:
    let
      packages = parsePackagesFromUsePackage (readFile config);
      overridden = override epkgs;
    in map (name: if hasAttr name overridden then
                    overridden.${name}
                  else
                    null)
           (packages ++ [ "use-package" ] ++ extraPackages ));
}
