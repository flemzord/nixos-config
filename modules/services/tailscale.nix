{ pkgs, ... }:

{
  services = {
    tailscale = {
      enable = true;
      openFirewall = true;
      useRoutingFeatures = "server";
    };
  };

  # Optimize UDP GRO forwarding for better Tailscale performance
  # https://tailscale.com/s/ethtool-config-udp-gro
  systemd.services.tailscale-udp-gro = {
    description = "Enable UDP GRO forwarding for Tailscale";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "enable-udp-gro" ''
        set -e
        NETDEV=$(${pkgs.iproute2}/bin/ip -o route get 8.8.8.8 | ${pkgs.coreutils}/bin/cut -f 5 -d " ")
        ${pkgs.ethtool}/bin/ethtool -K $NETDEV rx-udp-gro-forwarding on rx-gro-list off || true
      '';
    };
  };
}
