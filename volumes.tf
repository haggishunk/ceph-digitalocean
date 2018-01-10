resource "digitalocean_volume" "ceph-vol" {
    region                  = "${var.do_region}"
    count                   = "${var.instances}"
    name                    = "${var.prefix}-vol-${count.index+1}"
    size                    = "${var.size_vol}"
}
