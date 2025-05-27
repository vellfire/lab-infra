data "xenorchestra_pool" "xng1" {
  name_label = "xng1"
}

data "xenorchestra_sr" "xng1" {
  name_label = "Local storage"
  pool_id    = data.xenorchestra_pool.xng1.id
}

data "xenorchestra_network" "xng1" {
  name_label = "Pool-wide network associated with eth0"
  pool_id    = data.xenorchestra_pool.xng1.id
}

data "xenorchestra_template" "opnsense_template" {
  name_label = "OPNsense_template"
}

resource "xenorchestra_network" "xng1vlan50" {
  name_label        = "v.5G"
  name_description  = "VLAN 50 - OPNsense LAN # tf-managed"
  pool_id           = data.xenorchestra_pool.xng1.id
  source_pif_device = "eth0"
  mtu               = 9000
  vlan              = 50
}

resource "xenorchestra_network" "xng1vlan240" {
  name_label        = "v.Guest"
  name_description  = "VLAN 240 - Guest LAN # tf-managed"
  pool_id           = data.xenorchestra_pool.xng1.id
  source_pif_device = "eth0"
  mtu               = 1500
  vlan              = 240
}

resource "xenorchestra_network" "xng1vlan998" {
  name_label        = "v.WAN1"
  name_description  = "VLAN 998 - WAN1 # tf-managed"
  pool_id           = data.xenorchestra_pool.xng1.id
  source_pif_device = "eth0"
  mtu               = 1500
  vlan              = 998
}

data "xenorchestra_template" "debian12base" {
  name_label = "debian12base_template"
  pool_id    = data.xenorchestra_pool.xng1.id
}
