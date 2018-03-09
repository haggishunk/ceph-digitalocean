data "template_file" "newuser" {
  template = "${file("${path.root}/terraform-template-files/newuser-template.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "ssh-config" {
  template = "${file("${path.root}/terraform-template-files/ssh-config.sh")}"
}

data "template_file" "ssh-remote" {
  template = "${file("${path.root}/terraform-template-files/ssh-remote.sh")}"
}

data "template_file" "ceph-install" {
  template = "${file("${path.root}/terraform-template-files/ceph-install.sh")}"

  vars {
    user = "${var.user}"
  }
}

data "template_file" "inputrc" {
  template = "${file("${path.root}/terraform-template-files/inputrc")}"
}

data "template_file" "bashrc" {
  template = "${file("${path.root}/terraform-template-files/bashrc")}"

  vars {
    col1 = 39
    col2 = 202
  }
}
