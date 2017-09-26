variable project {
  description = "Google Cloud Project ID"
}

variable region {
  description = "Google Cloud Region"
  default     = "europe-west1"
}

variable public_key_path {
  description = "Path to the public key used for ssh access"
}

variable private_key_path {
  description = "Path to the private key used for ssh access"
}

variable app_disk_image {
  description = "Disk image with preinstalled Ruby and Puma"
}

variable db_disk_image {
  description = "Disk image with preinstalled MongoDB"
}

variable ssh_source_ranges {
  description = "Source ranges for SSH firewall (better to put here your own client IP, check at myip.com)"
  default     = ["0.0.0.0/0"]
}
