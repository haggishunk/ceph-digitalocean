# DigitalOcean vars

variable "admin_image" {
  type        = "string"
  description = "Admin image slug"
  default     = "debian-8-x64"
}

variable "image" {
  type        = "string"
  description = "Worker image slug"
  default     = "ubuntu-14-04-x64"
}

variable "worker_qty" {
  type        = "string"
  description = "Number of droplets to deploy"
  default     = "1"
}

variable "prefix" {
  type        = "string"
  description = "Basename of droplets"
  default     = "whateveryoulike"
}

variable "region" {
  # for this project you will want a region with volumes available
  type        = "string"
  description = "DigitalOcean droplet region"
  default     = "sfo2"
}

variable "size" {
  type        = "string"
  description = "Droplet RAM"
  default     = "1GB"
}

variable "size_vol" {
  type        = "string"
  description = "Volume size in GB"
  default     = 20
}

variable "ssh_id" {
  # change this
  type        = "string"
  description = "SSH public key ID - MD5 hash works: `ssh-keygen -l -E md5 -f ~/.ssh/id_rsa`"
  default     = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
}

variable "user" {
  type        = "string"
  description = "User to provision on each ceph node"
  default     = "tentacle"
}

variable "admin_cidr" {
  type        = "string"
  description = "Source CIDR block for SSH admin"
  default     = "0.0.0.0/0"
}
