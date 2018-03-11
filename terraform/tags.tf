resource "digitalocean_tag" "ceph" {
  name = "ceph"
}
resource "digitalocean_tag" "ceph-mon" {
  name = "ceph-mon"
}
resource "digitalocean_tag" "ceph-osd" {
  name = "ceph-osd"
}
