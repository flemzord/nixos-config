{
  services.qdrant = {
    enable = true;
    hsnw_index = {
      on_disk = true;
    };
    service = {
      host = "0.0.0.0";
      http_port = 6333;
      grpc_port = 6334;
    };
    storage = {
      snapshots_path = "/var/lib/qdrant/snapshots";
      storage_path = "/var/lib/qdrant/storage";
    };
    telemetry_disabled = true;
  };
}
