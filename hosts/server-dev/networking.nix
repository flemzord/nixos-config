{ ... }:
{
  networking = {
    usePredictableInterfaceNames = false;
    useDHCP = false;
    dhcpcd.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      # IPv4: Hetzner Cloud delivers the public /32 via DHCP from 172.31.1.1
      DHCP = "ipv4";
      # IPv6: static /64 with link-local gateway
      address = [ "2a01:4f9:c014:11b8::1/64" ];
      routes = [
        {
          Gateway = "fe80::1";
          GatewayOnLink = true;
        }
      ];
      networkConfig.IPv6AcceptRA = true;
      dns = [ "1.1.1.1" "9.9.9.9" ];
    };
  };
}
