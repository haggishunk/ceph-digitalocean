resource "digitalocean_droplet" "ceph" {
    image                   = "ubuntu-16-04-x64"
    count                   = "${var.instances}"
    name                    = "${var.prefix}-${count.index+1}"
    region                  = "${var.do_region}"
    size                    = "${var.size}"
    backups                 = "False"
    ipv6                    = "False"
    private_networking      = "True"
    ssh_keys                = ["${chomp(file("~/.ssh/id_rsa.fgr"))}"]


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
 
    # Add hosts to admin node ssh config file
    provisioner "local-exec" {
         command            = "python3 addNodesConfig.py ${var.node_user}"
    }

}

output "ceph_node_names" {
    value                   = "Your ceph node names are: ${join(", ", digitalocean_droplet.ceph.*.name)}"
}

output "ceph_nodes" {
    value                   = "Your ceph nodes are: ${join(", ", digitalocean_droplet.ceph.*.ipv4_address)}"
}
