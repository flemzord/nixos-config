{
  disko.devices = {
    disk = {
      nvme0 = {
        type = "disk";
        device = "/dev/nvme0n1";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02"; # BIOS boot partition for GRUB
            };
            boot = {
              size = "1G";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "mdraid";
                name = "swap";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
      nvme1 = {
        type = "disk";
        device = "/dev/nvme1n1";
        content = {
          type = "gpt";
          partitions = {
            bios = {
              size = "1M";
              type = "EF02";
            };
            boot = {
              size = "1G";
              content = {
                type = "mdraid";
                name = "boot";
              };
            };
            swap = {
              size = "32G";
              content = {
                type = "mdraid";
                name = "swap";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "mdraid";
                name = "root";
              };
            };
          };
        };
      };
    };
    mdadm = {
      boot = {
        type = "mdadm";
        level = 1;
        metadata = "1.0";
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/boot";
        };
      };
      swap = {
        type = "mdadm";
        level = 1;
        content = {
          type = "swap";
        };
      };
      root = {
        type = "mdadm";
        level = 1;
        content = {
          type = "filesystem";
          format = "ext4";
          mountpoint = "/";
        };
      };
    };
  };
}
