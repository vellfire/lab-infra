resource "oci_core_vcn" "vcn1" {
  cidr_block = "10.0.0.0/16"
  dns_label = "vcn1"
  compartment_id = var.compartment_id
  display_name ="vcn1"
}

resource "oci_core_internet_gateway" "inetGw" {
  compartment_id = var.compartment_id
  display_name = "inetGw"
  vcn_id = oci_core_vcn.vcn1.id
}
