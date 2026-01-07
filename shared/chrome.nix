{...}: {
  programs.chromium = {
    enable = true;
    extensions = [
      "fcoeoabgfenejglbffodgkkbkcdhcgfn" # Claude in Chrome
      "nngceckbapebfimnlniiiahkandclblb" # Bitwarden
    ];
  };
}
