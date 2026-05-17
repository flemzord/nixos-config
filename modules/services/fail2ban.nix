_:

{
  services.fail2ban = {
    enable = true;
    maxretry = 3;
    bantime = "2h";
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ];
    bantime-increment = {
      enable = true;
      maxtime = "7d";
      overalljails = true;
    };
    jails.sshd.settings = {
      backend = "systemd";
      enabled = true;
      filter = "sshd";
      findtime = "15m";
      maxretry = 3;
      mode = "aggressive";
      bantime = "2h";
    };
  };
}
