{ pkgs ? import <nixpkgs> {} }:

let
  # Commit of emmylua-analyzer-rust with the documentation generator fixes
  # required by the annotations in fun.lua (see HACKING.md).
  rev = "d563de1cb4ecce26111ad9153eca12ef6586a2be";

  src = pkgs.fetchFromGitHub {
    owner = "EmmyLuaLs";
    repo = "emmylua-analyzer-rust";
    inherit rev;
    hash = "sha256-zwqgJrKZFYwUwfG5sEyZGoKNd+4lAI9bhq2iZVmrLLk=";
  };

  # Build each tool from the same pinned revision, the way nixpkgs does.
  tool = { pname, dir }: pkgs.rustPlatform.buildRustPackage {
    inherit pname;
    version = "0.30.0";
    inherit src;
    buildAndTestSubdir = "crates/${dir}";
    cargoHash = "sha256-O3IvwtYBbZ0P6+h7HQ6gi7UxsupWuhNZxpfTuiXm0/k=";
    doCheck = false;
  };
in
pkgs.mkShell {
  name = "luafun";

  buildInputs = with pkgs; [
    (tool { pname = "emmylua-check"; dir = "emmylua_check"; })
    (tool { pname = "emmylua-doc-cli"; dir = "emmylua_doc_cli"; })
    git
    gnumake
    sphinx
    luajitPackages.luacheck
    mkdocs
    python312Packages.myst-parser
    sphinx-autobuild
  ];
}
