{
  services.k3s = {
    enable = true;
    role = "server";
    token = "mysupertokenwhichshouldnotbepublicbutwillbeanyway";
    clusterInit = true;
  };
}