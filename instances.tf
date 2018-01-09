resource "digitalocean_droplet" "ceph" {
    image = "ubuntu-16.04-lts"
    count = "${var.instances}"
    name = "${var.prefix}-${count.index+1}"
    region = "${var.do_region}"
    size = "${var.size}"
    backups = "False"
    ipv6 = "False"
    private_networking = "False"
    ssh_keys = ["${file("~/.ssh/id_rsa.fgr")}"]


    # remote connection key
    connection {
        type = "ssh"
        user = "root"
        private_key = "${file("~/.ssh/id_rsa")}"
    }

#    # Place your SSH public key on the
#    # remote machine to support the dokku setup
#    provisioner "file" {
#        source = "~/.ssh/id_rsa.pub"
#        destination = "/root/.ssh/id_rsa.pub"
#    }

#    # Stick the bootstrap.sh onto the
#    # remote machine to do the dokku setup
#    provisioner "file" {
#        source = "./bootstrap.sh"
#        destination = "/root/bootstrap.sh"
#    }

    # Update your remote VM and install dokku
    provisioner "remote-exec" {
        inline =    [   "apt-get -qq -y update",
                        "apt-get -qq -y install ntp",
                        "apt-get -qq -y install openssh-server",
                        "useradd -d /home/tentacle -m tentacle",
                        "echo 'tentacle ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/tentacle",
                        "chmod 0440 /etc/sudoers.d/tentacle",
                    ]
    }
 
}

# null resource used to reconnect to droplet
# after DNS record has been written
# (domain records should be available once
# app push is complete)
#resource "null_resource" "letsencrypt" {
#
#    depends_on = ["google_dns_record_set.mypaas", "google_dns_record_set.wildcard"]
#
#    # use this for remote connection 
#    connection {
#        host = "${digitalocean_droplet.mukku.0.ipv4_address}"
#        type = "ssh"
#        user = "root"
#        private_key = "${file("~/.ssh/id_rsa")}"
#    }
#
#    # Push app to dokku server
#    provisioner "local-exec" {
#         command = "sh app_pusher.sh ${digitalocean_droplet.mukku.0.ipv4_address} ${var.appname}"
#    }
#
#    # Configure let's encrypt plugin and request ssl cert for app
#    provisioner "remote-exec" {
#        inline = ["dokku config:set --no-restart ${var.appname} DOKKU_LETSENCRYPT_EMAIL='${var.email}'",
#                  "dokku letsencrypt ${var.appname}"]
#    }
#}

output "ceph_node_names" {
    value = "Your ceph node names are: ${join(", ", digitalocean_droplet.ceph.*.name)}"
}

output "ceph_nodes" {
    value = "Your ceph nodes are: ${join(", ", digitalocean_droplet.ceph.*.ipv4_address)}"
}
