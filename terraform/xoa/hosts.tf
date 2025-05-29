# xng1
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

data "xenorchestra_template" "opnsense_template" {
  name_label = "OPNsense_template"
  pool_id    = data.xenorchestra_pool.xng1.id
}

# xng2 - m720q
data "xenorchestra_pool" "m720q" {
  name_label = "m720q"
}

data "xenorchestra_sr" "m720q" {
  name_label = "Local storage"
  pool_id    = data.xenorchestra_pool.m720q.id
}

data "xenorchestra_network" "m720q_vlan1" {
  name_label = "Pool-wide network associated with eth0"
  pool_id    = data.xenorchestra_pool.m720q.id
}

resource "xenorchestra_network" "m720q_vlan50" {
  name_label        = "v.5G"
  name_description  = "VLAN 50 - OPNsense LAN # tf-managed"
  pool_id           = data.xenorchestra_pool.m720q.id
  source_pif_device = "eth0"
  mtu               = 9000
  vlan              = 50
}

resource "xenorchestra_network" "m720q_vlan240" {
  name_label        = "v.Guest"
  name_description  = "VLAN 240 - Guest LAN # tf-managed"
  pool_id           = data.xenorchestra_pool.m720q.id
  source_pif_device = "eth0"
  mtu               = 1500
  vlan              = 240
}

resource "xenorchestra_network" "m720q_vlan998" {
  name_label        = "v.WAN1"
  name_description  = "VLAN 998 - WAN1 # tf-managed"
  pool_id           = data.xenorchestra_pool.m720q.id
  source_pif_device = "eth0"
  mtu               = 1500
  vlan              = 998
}

data "xenorchestra_template" "m720q_debian12base" {
  name_label = "debian12base_template"
  pool_id    = data.xenorchestra_pool.m720q.id
}

data "xenorchestra_template" "m720q_opnsense_template" {
  name_label = "OPNsense_template"
  pool_id    = data.xenorchestra_pool.m720q.id
}
