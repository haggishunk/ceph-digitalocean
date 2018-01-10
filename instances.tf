resource "digitalocean_droplet" "ceph" {
    image                   = "ubuntu-16-04-x64"
    count                   = "${var.instances}"
    name                    = "${var.prefix}-${count.index+1}"
    region                  = "${var.do_region}"
    size                    = "${var.size}"
    volume_ids              = ["${element(digitalocean_volume.ceph-vol.*.id, count.index)}"]
    backups                 = "False"
    ipv6                    = "False"
    private_networking      = "True"
    ssh_keys                = ["${var.ssh_id}"]


    # remote connection key
    connection {
        type                = "ssh"
        user                = "root"
        private_key         = "${file("~/.ssh/id_rsa")}"
    }

    # Update your remote VM
    # provision node user
    # setup ssh access for admin node
    provisioner "remote-exec" {
        inline =    [   "apt-get -qq -y update",
                        "apt-get -qq -y install ntp",
                        "apt-get -qq -y install openssh-server",
                        "useradd -d /home/${var.node_user} -m ${var.node_user}",
                        "echo '${var.node_user} ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/${var.node_user}",
                        "chmod 0440 /etc/sudoers.d/${var.node_user}",
                        "mkdir /home/${var.node_user}/.ssh",
                        "cp /root/.ssh/authorized_keys /home/${var.node_user}/.ssh/authorized_keys",
                        "chown -R ${var.node_user}:${var.node_user} /home/${var.node_user}",
                        "chmod 0700 /home/${var.node_user}/.ssh",
                        "chmod  600 /home/${var.node_user}/.ssh/authorized_keys",
                    ]
    }

    provisioner "local-exec" {
        command =   "echo '\nHost ${self.name}\n    HostName ${self.ipv4_address}\n    User ${var.node_user}' | tee -a ~/.ssh/config"
    }
}

output "ceph_node_names" {
    value                   = "Your ceph node names are:\n${join(",\n", digitalocean_droplet.ceph.*.name)}"
}

output "ceph_nodes" {
    value                   = "Your ceph nodes are:\n${join(",\n", digitalocean_droplet.ceph.*.ipv4_address)}"
}
