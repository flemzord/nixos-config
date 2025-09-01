{
  # OctoPrint native NixOS service
  services.octoprint = {
    enable = true;
    port = 5000;
    openFirewall = true;
    
    # Configure plugins if needed
    plugins = plugins: with plugins; [
      # Add plugins here, for example:
      # stlviewer
      # themeify
    ];
    
    # Extra configuration for OctoPrint
    extraConfig = {
      server = {
        firstRun = false;
      };
      webcam = {
        # Enable webcam support if you have one
        stream = "/webcam/?action=stream";
        snapshot = "http://127.0.0.1:8080/?action=snapshot";
        ffmpeg = "/run/current-system/sw/bin/ffmpeg";
      };
      serial = {
        # Configure your printer's serial port
        port = "/dev/ttyUSB0";
        baudrate = 115200;
      };
      temperature = {
        profiles = [
          {
            name = "PLA";
            extruder = 200;
            bed = 60;
          }
          {
            name = "ABS";
            extruder = 230;
            bed = 110;
          }
        ];
      };
    };
  };
  
  # Ensure the octoprint user has access to the printer
  users.users.octoprint.extraGroups = [ "dialout" ];
}