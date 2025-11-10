output "fingerprints" {
  description = "Image fingerprints"
  value       = { for host, image in incus_image.image : host => image.fingerprint }
}

output "images" {
  description = "Images"
  value       = incus_image.image
}
