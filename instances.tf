resource "digitalocean_droplet" "ceph" {
    image = "ubuntu-16-04-x64"
    count = "${var.instances}"
    name = "${var.prefix}-${count.index+1}"
    region = "${var.do_region}"
    size = "${var.size}"
    backups = "False"
    ipv6 = "False"
    private_networking = "False"
    ssh_keys = ["${chomp(file("~/.ssh/id_rsa.fgr"))}"]


    # remote connection key
    connection {
        type = "ssh"
        user = "root"
        private_key = "${file("~/.ssh/id_rsa")}"
    }

    # Update your remote VM and provision user 'tentacle'
    provisioner "remote-exec" {
        inline =    [   "apt-get -qq -y update",
                        "apt-get -qq -y install ntp",
                        "apt-get -qq -y install openssh-server",
                        "useradd -d /home/tentacle -m tentacle",
                        "echo 'tentacle ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/tentacle",
                        "chmod 0440 /etc/sudoers.d/tentacle",
                        "mkdir /home/tentacle/.ssh",
                        "cp /root/.ssh/authorized_keys /home/tentacle/.ssh/authorized_keys",
                        "chown -R tentacle:tentacle /home/tentacle",
                        "chmod 0700 /home/tentacle/.ssh",
                        "chmod 600 /home/tentacle/.ssh/authorized_keys",
                    ]
    }
 
#    # Add hosts to admin node ssh config file
#    provisioner "local-exec" {
#         command = "echo '${digitalocean_droplet.ceph.ipv4_address}' | tee -a monkey.txt "
#    }
#
}

output "ceph_node_names" {
    value = "Your ceph node names are: ${join(", ", digitalocean_droplet.ceph.*.name)}"
}

output "ceph_nodes" {
    value = "Your ceph nodes are: ${join(", ", digitalocean_droplet.ceph.*.ipv4_address)}"
}
