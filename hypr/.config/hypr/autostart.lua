-- Extra autostart processes.

-- Software KVM: shares this machine's keyboard/mouse with the other Omarchy
-- box over the LAN. Peer, screen edge and TLS trust are per-host, configured
-- in hosts/<hostname>/.config/lan-mouse/config.toml.
o.launch_on_start("lan-mouse daemon")
