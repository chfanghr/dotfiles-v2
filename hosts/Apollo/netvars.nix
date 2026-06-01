let
  phyIface = "enp13s0f0np0";
  mainVlanIface = "vlan-main";
  mgmtVlanIface = "vlan-mgmt";

  mkNetKey = name: "40-${name}";
in {
  inherit phyIface mainVlanIface mgmtVlanIface;

  # Networkd unit keys (attribute names under `systemd.network.*`).
  phyNetKey = mkNetKey phyIface;
  mainVlanNetKey = mkNetKey mainVlanIface;
  mgmtVlanNetKey = mkNetKey mgmtVlanIface;
}
