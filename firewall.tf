resource "digitalocean_firewall" "ssh" {
  name = "ceph-ssh-22"

  droplet_ids = [
    "${digitalocean_droplet.ceph-admin.id}",
    "${digitalocean_droplet.ceph.*.id}",
  ]

  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "22"

      source_droplet_ids = [
        "${digitalocean_droplet.ceph-admin.id}",
      ]

      source_addresses = ["0.0.0.0/0"]
    },
  ]

  outbound_rule = [
    {
      protocol   = "tcp"
      port_range = "22"

      destination_droplet_ids = [
        "${digitalocean_droplet.ceph.*.id}",
      ]
    },
  ]
}

resource "digitalocean_firewall" "rgw" {
  name        = "ceph-rgw-thru-web"
  droplet_ids = ["${digitalocean_droplet.ceph.*.id}"]

  inbound_rule = [
    {
      protocol         = "tcp"
      port_range       = "80"
      source_addresses = ["0.0.0.0/0"]
    },
  ]

  outbound_rule = [
    {
      protocol              = "tcp"
      port_range            = "80"
      destination_addresses = ["0.0.0.0/0"]
    },
  ]
}

resource "digitalocean_firewall" "mon" {
  name = "ceph-allow-monitor"

  droplet_ids = [
    "${digitalocean_droplet.ceph.*.id}",
  ]

  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "6789"

      source_addresses = [
        "${digitalocean_droplet.ceph.*.ipv4_address}",
      ]
    },
  ]

  outbound_rule = [
    {
      protocol   = "tcp"
      port_range = "6789"

      destination_addresses = [
        "${digitalocean_droplet.ceph.*.ipv4_address}",
      ]
    },
  ]
}

resource "digitalocean_firewall" "osd" {
  name = "ceph-allow-osd"

  droplet_ids = [
    "${digitalocean_droplet.ceph.*.id}",
  ]

  inbound_rule = [
    {
      protocol   = "tcp"
      port_range = "6800-7300"

      source_addresses = [
        "${digitalocean_droplet.ceph.*.ipv4_address}",
        "${digitalocean_droplet.ceph.*.ipv4_address_private}",
      ]
    },
  ]

  outbound_rule = [
    {
      protocol   = "tcp"
      port_range = "6800-7300"

      destination_addresses = [
        "${digitalocean_droplet.ceph.*.ipv4_address}",
        "${digitalocean_droplet.ceph.*.ipv4_address_private}",
      ]
    },
  ]
}
