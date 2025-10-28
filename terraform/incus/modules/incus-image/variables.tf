variable "hosts" {
  description = "Set of hosts to pull the image to"
  type        = set(string)
}

variable "source_remote" {
  description = "Host to pull image from"
  type        = string
  default     = "images"
}

variable "image_name" {
  description = "Image name to pull"
  type        = string
}

variable "image_type" {
  description = "Image type"
  type        = string
  default     = "virtual-machine"
}

variable "architecture" {
  description = "Image architecture"
  type        = string
  default     = "x86_64"
}
