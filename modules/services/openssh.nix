_:

{
  services = {
    openssh = {
      enable = true;
      openFirewall = true;
      settings = {
        KbdInteractiveAuthentication = false;
        LogLevel = "VERBOSE";
        PasswordAuthentication = false;
        PermitRootLogin = "prohibit-password";
      };
    };
  };
}
