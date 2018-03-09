resource "digitalocean_firewall" "ssh" {
  name = "ceph-ssh-22"

  tags = ["${digitalocean_tag.ceph.name}"]

  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "22"

      source_addresses = ["${var.admin_cidr}"]
    },
  ]
}

resource "digitalocean_firewall" "ping" {
  name = "ceph-ping"

  tags = ["${digitalocean_tag.ceph.name}"]

  inbound_rule = [
    {
      protocol   = "icmp"
      port_range = "1-65535"

      source_addresses = ["${var.admin_cidr}",
                          "${digitalocean_droplet.ceph-admin.ipv4_address}",
                          "${digitalocean_droplet.ceph-admin.ipv4_address_private}",
                        ]
    },
  ]
}

resource "digitalocean_firewall" "rgw" {
  name = "ceph-rgw-thru-web"

  tags = ["${digitalocean_tag.ceph.name}"]

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

  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "6789"

      source_addresses = [
        "${digitalocean_droplet.ceph.*.ipv4_address}",
      ]
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
