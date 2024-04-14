{
  services.k3s = {
    enable = true;
    role = "server";
    token = "mysupertokenwhichshouldnotbepublicbutwillbeanyway";
    serverAddr = "https://100.69.131.75:6443";
  };
}