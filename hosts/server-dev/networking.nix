{ lib, ... }:
{
  networking = {
    usePredictableInterfaceNames = false;
    dhcpcd.enable = false;
  };

  systemd.network = {
    enable = true;
    networks."eth0" = {
      matchConfig.Name = "eth0";
      address = [
        "65.109.38.186/26"
        "2a01:4f9:5a:2402::2/64"
      ];
      routes = [
        { Gateway = "65.109.38.129"; }
        { Gateway = "fe80::1"; }
      ];
      dns = [ "1.1.1.1" "9.9.9.9" ];
    };
  };
}
