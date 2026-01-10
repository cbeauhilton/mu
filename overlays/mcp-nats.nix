# Overlay for mcp-nats - NATS MCP server
final: _prev: {
  mcp-nats = final.buildGoModule rec {
    pname = "mcp-nats";
    version = "0.1.3";

    src = final.fetchFromGitHub {
      owner = "sinadarbouy";
      repo = "mcp-nats";
      rev = "v${version}";
      hash = "sha256-BbMXWtYbj4HcTtV5szrme0XtXcuQ3LuTa6df8skhBxk=";
    };

    vendorHash = "sha256-uacbMaBZidQbg/OiYMDIqkrqTGCdjIRznjaUoAeOCwU=";

    subPackages = ["cmd/mcp-nats"];

    meta = with final.lib; {
      description = "MCP server for NATS messaging";
      homepage = "https://github.com/sinadarbouy/mcp-nats";
      license = licenses.mit;
      maintainers = [];
    };
  };
}
