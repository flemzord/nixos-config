let
  # User SSH public keys (for encrypting secrets)
  flemzord = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC33/UmOxIFBgPxxmr2qVqhN7wgdTLriKg4Em7MLi5KeIfWHs+Jqp7Fh6QDWwyOtRz8ARqtVlfZrO00xRAHx5UQkXmbd1iXeQgg7FPV+KuyAvAyfqciq0MJXFo5lIA9eO9TyFUKzC4dI/ayOubQDB8v5tCd+gYsW35eDrO5ueLi7ld2Q04lBO2mTNKoX0JUAd4+FYe9zkBXClh9ik0+F2IRBgG9HTVNqObUfXtpHp4iW0avXn7Syc4079rIkrwup7Swkxy1uo5nYeJSPHgnhDzjeCxzIal0UIDmPBHLAiuf8r2yWFb689jrmyfLYqN+o8QR2A5n+xQ5yxGmBDFKgkGN";

  # Host SSH public keys (ed25519 host keys from /etc/ssh/ssh_host_ed25519_key.pub)
  # Run on each host: cat /etc/ssh/ssh_host_ed25519_key.pub
  # home-hp = "ssh-ed25519 AAAA...";
  # home-dell = "ssh-ed25519 AAAA...";
  # dev-server = "ssh-ed25519 AAAA...";

  # All users who can decrypt secrets
  users = [ flemzord ];

  # All systems that need to decrypt secrets (add host keys here)
  # systems = [ home-hp home-dell dev-server ];

  # All keys (users + systems)
  allKeys = users; # ++ systems;
in
{
  # Cloudflare secrets
  "secrets/cloudflare-tunnel.json.age".publicKeys = allKeys;
  "secrets/cloudflare-cert.pem.age".publicKeys = allKeys;

  # SSH config (contains IPs)
  "secrets/ssh-config.age".publicKeys = allKeys;
}
