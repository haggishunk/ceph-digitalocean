##################
##ADMIN##########
################

resource "digitalocean_droplet" "ceph-admin" {
  image              = "${var.admin_image}"
  name               = "ceph-admin"
  region             = "${var.region}"
  size               = "${var.size}"
  backups            = "False"
  ipv6               = "False"
  private_networking = "True"
  monitoring         = "False"
  ssh_keys           = ["${var.ssh_id}"]

  tags = [
    "${digitalocean_tag.ceph.id}",
  ]

  connection {
    type = "ssh"
    user = "root"
  }

  # create non-root admin user
  provisioner "remote-exec" {
    inline = ["${data.template_file.newuser.rendered}"]
  }
}

resource "null_resource" "ceph-admin-config" {
  # do not run this until all ceph workers are created
  depends_on = ["null_resource.ceph-config"]

  # all further connections use admin user
  connection {
    host = "${digitalocean_droplet.ceph-admin.ipv4_address}"
    type = "ssh"
    user = "${var.user}"
  }

  # make bash pretty
  provisioner "file" {
    content     = "${data.template_file.bashrc.rendered}"
    destination = "/home/${var.user}/.bashrc"
  }

  # make terminal usable
  provisioner "file" {
    content     = "${data.template_file.inputrc.rendered}"
    destination = "/home/${var.user}/.inputrc"
  }

  # copy local ssh config files over to admin node
  # (repeat this for worker changes)
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ~/.ssh/config.d/ceph-*.ssh.config ${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~"
  }

  # Copy worker hosts file to admin node
  # (repeat this step for worker changes)
  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${path.root}/stuff/hosts_* ${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:/home/${var.user}/"
  }

  # corral ssh config definitions, hosts defs for worker nodes
  # create ssh pub/pri keypair for distribution to worker nodes
  # (repeat this step for worker changes)
  provisioner "remote-exec" {
    inline = ["${data.template_file.ssh-remote.rendered}"]
  }

  # copy admin node authorized keys to worker nodes
  # !!!need to scale this!!!
  # (repeat this for worker changes)
  provisioner "local-exec" {
    command = "scp -3 -o StrictHostKeyChecking=no ${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/authorized_keys ${var.user}@${digitalocean_droplet.ceph.0.ipv4_address}:~/.ssh/authorized_keys"
  }

  provisioner "local-exec" {
    command = "scp -3 -o StrictHostKeyChecking=no ${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/authorized_keys ${var.user}@${digitalocean_droplet.ceph.1.ipv4_address}:~/.ssh/authorized_keys"
  }

  provisioner "local-exec" {
    command = "scp -3 -o StrictHostKeyChecking=no ${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/authorized_keys ${var.user}@${digitalocean_droplet.ceph.2.ipv4_address}:~/.ssh/authorized_keys"
  }

  # copy file from admin to each worker to establish connection precedent
  # also requires scaling
  # (repeat this for worker changes)
  provisioner "remote-exec" {
    inline = [
      "touch ~/touchpoint",
      "scp -o StrictHostKeyChecking=no touchpoint ${var.user}@${digitalocean_droplet.ceph.0.ipv4_address}:~/touchpoint",
      "scp -o StrictHostKeyChecking=no touchpoint ${var.user}@${digitalocean_droplet.ceph.1.ipv4_address}:~/touchpoint",
      "scp -o StrictHostKeyChecking=no touchpoint ${var.user}@${digitalocean_droplet.ceph.2.ipv4_address}:~/touchpoint",
    ]
  }

  # Spit out ssh config file to ~/.ssh/config.d/
  # (repeat this only when admin node changes)
  provisioner "local-exec" {
    command = "echo 'Host ${digitalocean_droplet.ceph-admin.name}\n    HostName ${digitalocean_droplet.ceph-admin.ipv4_address}\n    User ${var.user}' | tee ~/.ssh/config.d/ceph-admin.ssh.config"
  }

  # Update your remote VM and install ceph
  provisioner "remote-exec" {
    inline = ["${data.template_file.ceph-install.rendered}"]
  }

}

##################
##NODES##########
################

resource "digitalocean_droplet" "ceph" {
  depends_on         = ["null_resource.pre-clean"]
  image              = "${var.image}"
  count              = "${var.worker_qty}"
  name               = "${var.prefix}-${count.index+1}"
  region             = "${var.region}"
  size               = "${var.size}"
  volume_ids         = ["${element(digitalocean_volume.ceph-vol.*.id, count.index)}"]
  backups            = "False"
  ipv6               = "False"
  private_networking = "True"
  monitoring         = "False"
  ssh_keys           = ["${var.ssh_id}"]

  tags = [
    "${digitalocean_tag.ceph.id}",
    "${digitalocean_tag.ceph-mon.id}",
    "${digitalocean_tag.ceph-osd.id}",
  ]

  # remote connection key
  connection {
    type = "ssh"
    user = "root"
  }

  # provision admin user and allow you to login in as said user
  provisioner "remote-exec" {
    inline = ["${data.template_file.newuser.rendered}"]
  }
}

resource "null_resource" "ceph-config" {
  count = "${var.worker_qty}"

  # remote connection key
  connection {
    type = "ssh"
    host = "${element(digitalocean_droplet.ceph.*.ipv4_address, count.index)}"
    user = "${var.user}"
  }

  # Update your remote VM
  # setup ssh access for admin node
  provisioner "remote-exec" {
    inline = [
      "sudo apt-get -y update",
      "sudo apt-get -y install python",
      "sudo apt-get -y install ntp",
      "sudo apt-get -y install openssh-server",
    ]
  }

  # make bash pretty
  provisioner "file" {
    content     = "${data.template_file.bashrc.rendered}"
    destination = "/home/${var.user}/.bashrc"
  }

  # make terminal usable
  provisioner "file" {
    content     = "${data.template_file.inputrc.rendered}"
    destination = "/home/${var.user}/.inputrc"
  }

  # generate local ssh `config` file to be copied to ceph-admin later
  provisioner "local-exec" {
    command = "echo '\nHost ${element(digitalocean_droplet.ceph.*.name, count.index)}\n    HostName ${element(digitalocean_droplet.ceph.*.ipv4_address, count.index)}\n    User ${var.user}' | tee ~/.ssh/config.d/ceph-${count.index}.ssh.config"
  }

  # spit out `/etc/hosts` entries to be copied to ceph-admin later
  # !!!could be done through dns or with reverse proxy(?) instead!!!
  provisioner "local-exec" {
    command = "echo '${element(digitalocean_droplet.ceph.*.ipv4_address, count.index)} ${element(digitalocean_droplet.ceph.*.name, count.index)} ${element(digitalocean_droplet.ceph.*.name, count.index)}' | tee ${path.root}/stuff/hosts_${element(digitalocean_droplet.ceph.*.name, count.index)}"
  }
}

##################
##PRE-CLEANING###
################

resource "null_resource" "pre-clean" {
  provisioner "local-exec" {
    command = "rm ~/.ssh/config.d/ceph-*.ssh.config || echo \"No ceph ssh config files found\" ; rm ${path.root}/stuff/hosts_* || echo \"No hosts file found in module root\""
  }
}

##################
##OUTPUT#########
################

output "ceph_admin" {
  value = "${digitalocean_droplet.ceph-admin.0.name} (${digitalocean_droplet.ceph-admin.0.ipv4_address}) (${digitalocean_droplet.ceph-admin.0.ipv4_address_private})"
}

output "ceph_node_names" {
  value = "Your ceph node names are:\n${join(",\n", digitalocean_droplet.ceph.*.name)}"
}

output "ceph_nodes_pub" {
  value = "\nYour ceph nodes' public IPs are:\n${join(",\n", digitalocean_droplet.ceph.*.ipv4_address)}"
}

output "ceph_nodes_pri" {
  value = "\nYour ceph nodes' private IPs are:\n${join(",\n", digitalocean_droplet.ceph.*.ipv4_address_private)}"
}
