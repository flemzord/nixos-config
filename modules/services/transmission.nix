_:

let
  downloadDir = "/srv/media";
  incompleteDir = "/srv/media/.incomplete";
  runUser = "flemzord";
  runGroup = "users";
in
{
  # Ensure the incomplete directory exists
  systemd.tmpfiles.rules = [
    "d ${incompleteDir} 0775 ${runUser} ${runGroup} -"
  ];

  services.transmission = {
    enable = true;
    user = runUser;
    group = runGroup;
    openFirewall = true;
    openRPCPort = true; # 9091
    performanceNetParameters = true;
    settings = {
      "download-dir" = downloadDir;
      "incomplete-dir" = incompleteDir;
      "incomplete-dir-enabled" = true;

      # RPC/Web UI
      "rpc-bind-address" = "0.0.0.0";
      "rpc-whitelist-enabled" = false;
      # "rpc-authentication-required" = true; # Uncomment and set credentials if desired
      # "rpc-username" = "transmission";
      # "rpc-password" = "CHANGEME"; # Will be hashed on first run

      # Permissions
      "umask" = 2; # 002 -> files 664, dirs 775

      # Misc
      "blocklist-enabled" = true;
      "blocklist-url" = "https://github.com/sahsu/transmission-blocklist/releases/latest/download/blocklist.gz";
    };
  };
}
