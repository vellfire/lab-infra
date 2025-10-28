resource "incus_image" "image" {
  for_each = var.hosts
  remote   = each.value

  source_image = {
    remote       = var.source_remote
    name         = var.image_name
    type         = var.image_type
    architecture = var.architecture
  }
}
