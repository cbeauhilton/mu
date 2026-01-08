# Network tools
{pkgs, ...}: {
  home.packages = with pkgs; [
    iperf3
    mtr
    nmap
    whois
  ];
}
