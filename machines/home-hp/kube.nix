{
  services.k3s = {
    enable = true;
    role = "server";
    token = "mysupertokenwhichshouldnotbepublicbutwillbeanyway";
    serverAddr = "https://192.168.1.119:6443";
    extraFlags = "--disable=servicelb --disable-helm-controller --disable=traefik";
  };
}