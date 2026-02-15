# Prefer direct LAN path over Tailscale subnet route when on the same network.
#
# Tailscale's routing table (52) at priority 5270 captures 10.0.0.0/24 via a
# subnet router, even when this device is physically on the LAN. This adds a
# rule at priority 5269 that checks the main table first:
#   - On LAN: main has a DHCP route for 10.0.0.0/24 → direct path (fast)
#   - Remote: main has no such route → falls through to table 52 → Tailscale
{pkgs, ...}: {
  systemd.services.lan-route-priority = {
    description = "Prefer LAN route over Tailscale for local subnet";
    after = ["tailscaled.service" "network-online.target"];
    wants = ["network-online.target"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.iproute2}/bin/ip rule add to 10.0.0.0/24 lookup main priority 5269";
      ExecStop = "${pkgs.iproute2}/bin/ip rule del to 10.0.0.0/24 lookup main priority 5269";
    };
  };
}
