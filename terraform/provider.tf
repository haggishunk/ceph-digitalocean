provider "digitalocean" {
    token = "${chomp(file("~/.creds/do_token"))}"
}
