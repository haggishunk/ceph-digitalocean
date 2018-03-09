##################
##ADMIN##########
################

resource "digitalocean_droplet" "ceph-admin" {
  depends_on         = ["digitalocean_droplet.ceph"]
  image              = "${var.admin_image}"
  name               = "ceph-admin"
  region             = "${var.region}"
  size               = "${var.size}"
  backups            = "False"
  ipv6               = "False"
  private_networking = "True"
  monitoring         = "False"
  ssh_keys           = ["${var.ssh_id}"]

  # remote root connection key
  connection {
    type = "ssh"
    user = "root"
  }

  # provision admin user and allow you to login in as said user
  provisioner "remote-exec" {
    inline = ["${data.template_file.newuser.rendered}"]
  }

  provisioner "local-exec" {
    command = "echo '\nHost ${self.name}\n    HostName ${self.ipv4_address}\n    User ${var.user}' | tee -a ~/.ssh/config.d/ceph-admin.config"
  }

  provisioner "local-exec" {
    command = "scp -o StrictHostKeyChecking=no ${path.root}/stuff/hosts_file ${self.name}:/home/${var.user}/hosts_file"
  }
}

resource "null_resource" "admin-config" {
  # remote ceph-admin connection key
  connection {
    host = "${digitalocean_droplet.ceph-admin.ipv4_address}"
    type = "ssh"
    user = "${var.user}"
  }

  # Update your remote VM and install ceph
  # Generate ssh key locally (make password-less & comment-less) &&
  #     append to authorized_keys for copying out to worker nodes later
  # Append ceph hosts to /etc/hosts
  provisioner "remote-exec" {
    inline = ["${data.template_file.ceph-install.rendered}"]
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
  provisioner "local-exec" {
    command = <<EOF
scp -o StrictHostKeyChecking=no 
~/.ssh/config.d/ceph-* 
${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/config.d/
EOF
  }

  # copy admin node authorized keys to worker nodes
  # !!!need to scale this!!!
  provisioner "local-exec" {
    command = <<EOF
scp -3 -o StrictHostKeyChecking=no 
${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/authorized_keys
${var.user}@${digitalocean_droplet.ceph.0.ipv4_address}:~/.ssh/authorized_keys
EOF
  }
  
  provisioner "local-exec" {
    command = <<EOF
scp -3 -o StrictHostKeyChecking=no 
${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/authorized_keys
${var.user}@${digitalocean_droplet.ceph.0.ipv4_address}:~/.ssh/authorized_keys
EOF
  }
  
  provisioner "local-exec" {
    command = <<EOF
scp -3 -o StrictHostKeyChecking=no 
${var.user}@${digitalocean_droplet.ceph-admin.ipv4_address}:~/.ssh/authorized_keys
${var.user}@${digitalocean_droplet.ceph.0.ipv4_address}:~/.ssh/authorized_keys
EOF
  }
  
  # copy file from admin to each worker to establish connection precedent
  # also requires scaling
  provisioner "remote-exec" {
    inline = [
      "touch ~/touchpoint",
      "scp -o StrictHostKeyChecking=no touchpoint ${var.user}@${digitalocean_droplet.ceph.0.ipv4_address}:~/touchpoint",
      "scp -o StrictHostKeyChecking=no touchpoint ${var.user}@${digitalocean_droplet.ceph.1.ipv4_address}:~/touchpoint",
      "scp -o StrictHostKeyChecking=no touchpoint ${var.user}@${digitalocean_droplet.ceph.2.ipv4_address}:~/touchpoint",
    ]
  }
}

##################
##NODES##########
################

resource "digitalocean_droplet" "ceph" {
  depends_on         = ["null_resource.pre-clean"]
  image              = "${var.node_image}"
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

  # remote connection key
  connection {
    type = "ssh"
    user = "root"
  }

  # provision admin user and allow you to login in as said user
  provisioner "remote-exec" {
    inline = ["${data.template_file.newuser.rendered}"]
  }

  # Update your remote VM
  # setup ssh access for admin node
  provisioner "remote-exec" {
    inline = [
      "apt-get -qq -y update",
      "apt-get -qq -y install python",
      "apt-get -qq -y install ntp",
      "apt-get -qq -y install openssh-server",
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
    command = "echo '\nHost ${self.name}\n    HostName ${self.ipv4_address}\n    User ${var.user}' | tee ~/.ssh/config.d/ceph-${count.index}.config"
  }

  # spit out `/etc/hosts` entries to be copied to ceph-admin later
  # !!!could be done through dns or with reverse proxy(?) instead!!!
  provisioner "local-exec" {
    command = "echo '${self.ipv4_address} ${self.name} ${self.name}' | tee -a ${path.root}/hosts_file"
  }
}

##################
##PRE-CLEANING###
################

resource "null_resource" "pre-clean" {
  provisioner "local-exec" {
    command = <<EOF
rm ~/.ssh/config.d/ceph-* || echo "No ceph ssh config files found"
rm ${path.root}/hosts_file || echo "No hosts file found in module root"
EOF
  }
}

##################
##OUTPUT#########
################

output "ceph_admin" {
  value = "Your admin node is:\n${digitalocean_droplet.ceph-admin.0.name} (${digitalocean_droplet.ceph-admin.0.ipv4_address}) (${digitalocean_droplet.ceph-admin.0.ipv4_address_private})"
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
