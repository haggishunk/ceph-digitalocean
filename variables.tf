# DigitalOcean vars

variable "instances" {
    type = "string"
    description = "Number of droplets to deploy"
    default = "1"
}

variable "prefix" {
    type = "string"
    description = "Basename of droplets"
    default = "whateveryoulike"
}

variable "do_region" {
    type = "string"
    description = "DigitalOcean droplet region"
    default = "sfo2"
}

variable "size" {
    type = "string"
    description = "Droplet RAM"
    default = "512MB"
}

variable "ssh_id" {
    # change this
    type = "string"
    description = "SSH public key ID - MD5 hash works - `ssh-keygen -l -E md5 -f ~/.ssh/id_rsa`"
    default = "xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx:xx"
}

variable "node_user" {
    type = "string"
    description = "User to provision on each ceph node"
    default = "tentacle"
}

# GCP vars

variable "gcp_dns_zone" {
    # change this
    type = "string"
    description = "GCP DNS managed zone name"
    default = "yourzone"
}

variable "gcp_region" {
    type = "string"
    description = "GCP VM region selection"
    default = "us-west1"
}


# Shared/misc  vars
variable "domain" {
    # change this
    type = "string"
    description = "The base domain"
    default = "domain.tld"
}

variable "email" {
    # change this
    # note: unicode \u003C and \u003Efor angle brackets
    type = "string"
    description = "Email address for CSR to Let's Encrypt"
    default = "\u003Cperson@domain.tld\u003E"
}
