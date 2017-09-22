variable project {
  description = "Project ID"
}

variable region {
  description = "Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for connection provisioners"
}

variable app_disk_image {
  description = "Disk image for reddit app"
  default     = "reddit-app-1506075690"
}

variable db_disk_image {
  description = "Disk image for reddit db"
  default     = "reddit-db-1506075374"
}

variable ssh_source_ranges {
  description = "Source ranges for SSH firewall"
  default     = ["31.13.17.20/32"]
}
