{ lib, ... }:
{
  networking = {
    nameservers = [ "1.1.1.1" "9.9.9.9" ];
    defaultGateway = {
      address = "65.109.38.129";
      interface = "eno1";
    };
    defaultGateway6 = {
      address = "fe80::1";
      interface = "eno1";
    };
    dhcpcd.enable = false;
    usePredictableInterfaceNames = lib.mkForce true;
    interfaces = {
      eno1 = {
        ipv4.addresses = [
          { address = "65.109.38.186"; prefixLength = 26; }
        ];
        ipv6.addresses = [
          { address = "2a01:4f9:5a:2402::2"; prefixLength = 64; }
          { address = "fe80::52eb:f6ff:fe2f:341f"; prefixLength = 64; }
        ];
      };
    };
  };

  services.udev.extraRules = ''
    ATTR{address}=="50:eb:f6:2f:34:1f", NAME="eno1"
  '';
}
