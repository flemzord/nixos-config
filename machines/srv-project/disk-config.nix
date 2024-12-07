{lib, ...}: let
  one = "/dev/nvme0n1";
  two = "/dev/nvme1n1";
  content = {
    type = "gpt";
    partitions = {
      boot = {
        name = "boot";
        size = "1M";
        type = "EF02";
      };
      raid1 = {
        size = "1G";
        content = {
          type = "mdraid";
          name = "braid";
        };
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
    braid = { # stands for boot raid
      type = "mdadm";
      level = 1;
      content = {
        type = "filesystem";
        format = "ext4";
        mountpoint = "/boot";
      };
    };
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