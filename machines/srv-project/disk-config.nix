{lib, ...}: let
  one = "/dev/nvme0n1";
  two = "/dev/nvme0n1";
  content = {
    type = "gpt";
    partitions = {
      boot = {
        type = "EF00";
        start = "1MiB";
        end = "500MiB";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot";
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