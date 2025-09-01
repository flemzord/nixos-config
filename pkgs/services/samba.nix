{ config, pkgs, lib, ... }:

let
  sharePath = "/srv/media";
  ownerUser = "flemzord";
  ownerGroup = "users";
in
{
  # Ensure share directory exists with sensible permissions
  systemd.tmpfiles.rules = [
    "d ${sharePath} 0775 ${ownerUser} ${ownerGroup} -"
  ];

  services = {
    samba = {
      enable = true;
      # Open firewall for SMB/CIFS
      openFirewall = true;

      # New-style INI settings with explicit sections
      settings = {
        global = {
          "workgroup" = "WORKGROUP";
          "server string" = "home-dell";
          "map to guest" = "Bad User";
          "smb encrypt" = "desired";
        };

        media = {
          path = sharePath;
          browseable = "yes";
          "read only" = "yes";
          "guest ok" = "yes";
          # Allow writes only for authenticated users listed here
          "write list" = ownerUser;
          "force user" = ownerUser;
          "force group" = ownerGroup;
          "create mask" = "0664";
          "directory mask" = "0775";
        };
      };
    };

    # WS-Discovery for Windows network discovery without legacy NetBIOS
    samba-wsdd.enable = true;

    # Advertise SMB over mDNS/Bonjour so Apple/iOS clients (Infuse) can discover it
    avahi = {
      enable = true;
      publish = {
        enable = true;
        workstation = true;
      };
      extraServiceFiles.smb = ''
        <?xml version="1.0" standalone='no'?>
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };
}
