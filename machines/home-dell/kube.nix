{
  services.k3s = {
    enable = true;
    role = "server";
    token = "mysupertokenwhichshouldnotbepublicbutwillbeanyway";
    clusterInit = true;
    extraFlags = "--disable=servicelb --disable-helm-controller --disable=traefik"
  };
}