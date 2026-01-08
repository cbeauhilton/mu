{pkgs, ...}: {
  home.packages = with pkgs; [
    (azure-cli.withExtensions [
      azure-cli.extensions.aks-preview
      azure-cli-extensions.virtual-wan
      spice
      spice-gtk
      spice-protocol
      virt-viewer
    ])
  ];
  dconf.settings = {
    "org/virt-manager/virt-manager/connections" = {
      autoconnect = ["qemu:///system"];
      uris = ["qemu:///system"];
    };
  };
}
