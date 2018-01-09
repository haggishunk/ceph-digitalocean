provider "digitalocean" {
    token = "${file("~/.creds/do_token")}"
}
