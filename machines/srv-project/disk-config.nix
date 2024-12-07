{lib, ...}: let
  one = "/dev/nvme0n1";
  two = "/dev/nvme0n1";
  content = {
    type = "gpt";
    partitions = {
      boot = {
        name = "boot";
        size = "1G";
        type = "ext4";
      };
      raid2 = {
        size = "100%";
        content = {
          type = "mdraid";
          name = "rraid";
        };
      };
    };
  };
in {
  disko.devices.disk = {
    one = {
      inherit content;
      type = "disk";
      device = one;
    };
    two = {
      inherit content;
      type = "disk";
      device = two;
    };
  };
  disko.devices.mdadm = {
    rraid = { # stands for root raid
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/";
        mountOptions = ["defaults"];
      };
    };
  };
}