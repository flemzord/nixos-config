{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        # Hetzner Cloud vServer boot disk (152 GB). The Cloud Volume
        # (/dev/sda, scsi-0HC_Volume_*) is intentionally NOT listed here
        # so disko never touches it.
        device = "/dev/disk/by-id/scsi-0QEMU_QEMU_HARDDISK_116731138";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
    };
  };
}
