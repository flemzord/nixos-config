{ lib, ... }: let
  one = "/dev/nvme0n1";
  two = "/dev/nvme1n1";

  content = {
    type = "gpt";
    partitions = {
      boot = {
        name = "boot";
        size = "500M";
        type = "EF00";
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
    braid = {
      type = "mdadm";
      level = 1;
      content = {
        type = "gpt";
        partitions = {
          p1 = {
            size = "100%";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              mountOptions = [ "umask=0077" ];
            };
          };
        };
      };
    };

    rraid = {
      type = "mdadm";
      level = 1;
      content = {
        type = "gpt";
        partitions = {
          p1 = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = ["defaults"];
            };
          };
        };
      };
    };
  };
}