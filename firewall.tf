resource "digitalocean_firewall" "ssh" {
  name = "ceph-ssh-22"

  tags = ["${digitalocean_tag.ceph.name}"]

  # permit ssh connections from admin CIDR
  # and any droplet with a ceph tag
  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "22"

      source_addresses = ["${var.admin_cidr}"]

      source_tags = ["${digitalocean_tag.ceph.name}"]
    },
  ]
}

resource "digitalocean_firewall" "ping" {
  name = "ceph-ping"

  tags = ["${digitalocean_tag.ceph.name}"]

  # permit pings from admin CIDR
  # and any droplet with a ceph tag
  inbound_rule = [
    {
      protocol   = "icmp"
      port_range = "1-65535"

      source_addresses = ["${var.admin_cidr}"]

      source_tags = ["${digitalocean_tag.ceph.name}"]
    },
  ]
}

resource "digitalocean_firewall" "rgw" {
  name = "ceph-rgw-thru-web"

  tags = ["${digitalocean_tag.ceph.name}"]
  
  # permit inbound http port 80 connections from anywhere (users)
  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0"]
    },
  ]
}

resource "digitalocean_firewall" "mon" {
  name = "ceph-allow-monitor"

  tags = ["${digitalocean_tag.ceph.name}"]

  # permit monitor cross-talk between all ceph-tagged nodes
  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "6789"

      source_tags = ["${digitalocean_tag.ceph.name}"]
    },
  ]
}

resource "digitalocean_firewall" "outbound" {
  name = "ceph-update"

  tags = ["${digitalocean_tag.ceph.name}"]

  outbound_rule = [
    {
      protocol   = "tcp"
      port_range = "1-65535"

      destination_addresses = ["0.0.0.0/0"]
    },
    {
      protocol   = "udp"
      port_range = "1-65535"

      destination_addresses = ["0.0.0.0/0"]
    },
    {
      protocol   = "icmp"
      port_range = "1-65535"

      destination_addresses = ["0.0.0.0/0"]
    },
  ]
}
