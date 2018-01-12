
##################
##ADMIN##########
################

resource "digitalocean_droplet" "ceph-admin" {
    depends_on              = ["digitalocean_droplet.ceph"]
    image                   = "${var.admin_image}"
    name                    = "ceph-admin"
    region                  = "${var.do_region}"
    size                    = "${var.size}"
    backups                 = "False"
    ipv6                    = "False"
    private_networking      = "True"
    ssh_keys                = ["${var.ssh_id}"]


    # remote root connection key
    connection {
        type                = "ssh"
        user                = "root"
        private_key         = "${file("~/.ssh/id_rsa")}"
    }

    # provision admin user and allow you to login in as said user
    provisioner "remote-exec" {
        inline =    [   "useradd -d /home/${var.admin_user} -m ${var.admin_user}",
                        "echo '${var.admin_user} ALL = (root) NOPASSWD:ALL' | tee /etc/sudoers.d/${var.admin_user}",
                        "chmod 0440 /etc/sudoers.d/${var.admin_user}",
                        "mkdir /home/${var.admin_user}/.ssh",
                        "cp /root/.ssh/authorized_keys /home/${var.admin_user}/.ssh/authorized_keys",
                        "chown -R ${var.admin_user}:${var.admin_user} /home/${var.admin_user}",
                        "chmod 0700 /home/${var.admin_user}/.ssh",
                        "chmod  600 /home/${var.admin_user}/.ssh/authorized_keys",
                    ]
    }

    provisioner "local-exec" {
        command =   "echo '\nHost ${self.name}\n    HostName ${self.ipv4_address}\n    User ${var.admin_user}' | tee -a ~/.ssh/config.d/ceph-digitalocean"
    }

    provisioner "local-exec" {
        command =   "scp -o StrictHostKeyChecking=no ${path.root}/hosts_file ${self.name}:/home/${var.admin_user}/hosts_file"
    }

}

resource "null_resource" "admin-config" {
    depends_on          = ["digitalocean_droplet.ceph-admin"]

    # remote ceph-admin connection key
    connection {
        host                = "${digitalocean_droplet.ceph-admin.0.ipv4_address}"
        type                = "ssh"
        user                = "${var.admin_user}"
        private_key         = "${file("~/.ssh/id_rsa")}"
    }

    # Update your remote VM and install ceph
    # Generate ssh key locally (make password-less & comment-less) &&
    #     append to authorized_keys for copying out to worker nodes later
    # Append ceph hosts to /etc/hosts
    provisioner "remote-exec" {
        inline =    [  
                        "sudo apt-get -qq update",
                        "sudo apt-get -qq -y install ceph-deploy",
                        "ssh-keygen -t rsa -b 4096 -f /home/${var.admin_user}/.ssh/id_rsa -N '' -C '' ",
                        "cat /home/${var.admin_user}/.ssh/id_rsa.pub | tee -a /home/${var.admin_user}/.ssh/authorized_keys",
                        "sudo cat /home/${var.admin_user}/hosts_file | sudo tee -a /etc/hosts",
                    ]
    }

    # copy local ssh config file over to admin node
    provisioner "local-exec" {
        command = "scp -o StrictHostKeyChecking=no ~/.ssh/config.d/ceph-digitalocean ceph-admin:~/.ssh/config"
    }

    # copy admin node authorized keys to worker nodes
    # !!!need to scale this!!!
    provisioner "local-exec" {
        command = "scp -3 -o StrictHostKeyChecking=no ceph-admin:~/.ssh/authorized_keys ceph-1:~/.ssh/authorized_keys"
    }
    provisioner "local-exec" {
        command = "scp -3 -o StrictHostKeyChecking=no ceph-admin:~/.ssh/authorized_keys ceph-2:~/.ssh/authorized_keys"
    }
    provisioner "local-exec" {
        command = "scp -3 -o StrictHostKeyChecking=no ceph-admin:~/.ssh/authorized_keys ceph-3:~/.ssh/authorized_keys"
    }

}

##################
##NODES##########
################

resource "digitalocean_droplet" "ceph" {
    image                   = "${var.node_image}"
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
                        "apt-get -qq -y install python",
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

    # generate local ssh `config` file to be copied to ceph-admin later
    provisioner "local-exec" {
        command =   "echo '\nHost ${self.name}\n    HostName ${self.ipv4_address}\n    User ${var.node_user}' | tee -a ~/.ssh/config.d/ceph-digitalocean"
    }

    # spit out `/etc/hosts` entries to be copied to ceph-admin later
    # !!!could be done through dns or with reverse proxy(?) instead!!!
    provisioner "local-exec" {
        command =   "echo '${self.ipv4_address} ${self.name} ${self.name}' | tee -a ${path.root}/hosts_file"
    }
}

##################
##OUTPUT#########
################

output "ceph_admin"  {
    value                   = "Your admin node is:\n${digitalocean_droplet.ceph-admin.0.name}"
}

output "ceph_node_names" {
    value                   = "Your ceph node names are:\n${join(",\n", digitalocean_droplet.ceph.*.name)}"
}

output "ceph_nodes_pub" {
    value                   = "\nYour ceph nodes' public IPs are:\n${join(",\n", digitalocean_droplet.ceph.*.ipv4_address)}"
}

output "ceph_nodes_pri" {
    value                   = "\nYour ceph nodes' private IPs are:\n${join(",\n", digitalocean_droplet.ceph.*.ipv4_address_private)}"
}
