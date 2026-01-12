# tree-sitter-datastar package
# Builds the datastar tree-sitter grammar for neovim
#
# To update:
#   nix run nixpkgs#nix-prefetch-github -- YuryKL tree-sitter-datastar
# Then update rev and hash below, then: just switch
{
  stdenv,
  fetchFromGitHub,
  lib,
}:
stdenv.mkDerivation rec {
  pname = "tree-sitter-datastar";
  version = "unstable-2025-01-12";

  src = fetchFromGitHub {
    owner = "YuryKL";
    repo = "tree-sitter-datastar";
    rev = "27aa8ebe9c9e6dc7ba8c004b1b6abe801f5a2070";
    hash = "sha256-bYSxRNvMvhwqD1ErLo4d/4uymKARA91xVONYR9L95jw=";
  };

  buildPhase = ''
    # Compile the parser
    $CC -shared -fPIC -o datastar.so src/parser.c src/scanner.c -I./src
  '';

  installPhase = ''
    # Install parser
    mkdir -p $out/parser
    cp datastar.so $out/parser/

    # Install queries for nvim
    mkdir -p $out/queries/datastar
    cp queries/highlights.scm $out/queries/datastar/
    cp queries/indents.scm $out/queries/datastar/
    cp queries/injections-nvim.scm $out/queries/datastar/injections.scm
    cp queries/textobjects.scm $out/queries/datastar/
  '';

  meta = with lib; {
    description = "Tree-sitter grammar for Datastar";
    homepage = "https://github.com/YuryKL/tree-sitter-datastar";
    license = licenses.mit;
    platforms = platforms.unix;
  };
}
