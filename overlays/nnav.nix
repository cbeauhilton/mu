# Overlay for nnav - NATS Navigator TUI
final: _prev: {
  nnav = final.python3Packages.buildPythonApplication rec {
    pname = "nnav";
    version = "0-unstable-2025-06-11";

    src = final.fetchFromGitHub {
      owner = "tallpress";
      repo = "nnav";
      rev = "573a2b290b06d9032c150c67257249064b893caa";
      hash = "sha256-Tgop4dG+Lu7bmbkUrV6np2lOTkUYmr0QwlolUn9WX4E=";
    };

    build-system = with final.python3Packages; [
      hatchling
    ];

    dependencies = with final.python3Packages; [
      nats-py
      textual
      click
    ];

    meta = with final.lib; {
      description = "TUI for exploring NATS messages with filtering and JSON tools";
      homepage = "https://github.com/tallpress/nnav";
      license = licenses.mit;
    };
  };
}
