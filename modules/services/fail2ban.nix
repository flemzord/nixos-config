_:

{
  services.fail2ban = {
    enable = true;
    maxretry = 4;
    bantime = "1h";
    ignoreIP = [
      "127.0.0.1/8"
      "::1"
    ];
    bantime-increment = {
      enable = true;
      maxtime = "24h";
      overalljails = true;
    };
    jails.sshd.settings = {
      enabled = true;
      mode = "aggressive";
      maxretry = 4;
      findtime = "10m";
      bantime = "1h";
    };
  };
}
