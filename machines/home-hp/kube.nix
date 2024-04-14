{
  services.k3s = {
    enable = true;
    role = "server";
    token = "mysupertokenwhichshouldnotbepublicbutwillbeanyway";
    serverAddr = "https://192.168.1.119:6443";
  };
}