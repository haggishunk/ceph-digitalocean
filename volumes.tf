resource "digitalocean_volume" "ceph-vol" {
    region                  = "${var.region}"
    count                   = "${var.worker_qty}"
    name                    = "${var.prefix}-vol-${count.index}"
    size                    = "${var.size_vol}"
}
