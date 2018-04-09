variable project {
  description = "Project ID"
}

variable zone {
  description = "Name zone in GCP"
  default     = "europe-west1-b"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
  default     = "~/.ssh/id_rsa.pub"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
  default     = "~/.ssh/id_rsa"
}

variable disk_image {
  description = "Disk image"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-base"
}

variable app_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-app-base"
}
