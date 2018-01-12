# Ceph Cluster on Digital Ocean
(currently just the instance provisioning & configuration)

### Purpose

[Ceph][] is a cool open-source cluster storage solution that features device, block & object storage.

### Usage

1. Install [Terraform][]

2. Clone the repo
```
git clone https://github.com:haggishunk/ceph-digitalocean.git
cd ceph-digitalocean
```

3. Add an include statment to the head of your SSH config file
```
Include config.d/*
```

4. Create an SSH config subdirectory
```
mkdir ~/.ssh/config.d
```

5. Make changes to terraform config files

`terraform.tfvars`
* `ssh_id:` change to your DigitalOcean SSH key md5 fingerprint
* `instances:` change to desired number of nodes, min 3 _(optional)_
* `do_region:` change to desired DigitalOcean instance region, select a region with [volume availability][] _(optional)_

`provider.tf`
* `token:` change file path to location of your DigitalOcean token string

`instances.tf`
* `connection - private_key:` ensure private key file matches fingerprint specified with `ssh_id` above

6. Initialize
```
terraform init
```

7. Plan
```
terraform plan
```

8. Deploy
```
terraform apply
```

Respond with 'yes' at the prompt.

9. When the deployment is complete you should be able to SSH into the node names listed in Terraform's output directly from your local machine, for example:
```
ssh ceph-admin
```

and from the admin node to the worker nodes, por ejemplo:
```
ssh ceph-1
```

You are now complete with the `ceph-deploy` [preflight][] instructions and you can begin [storage cluster setup][].  Future developments to this module will implement these steps in Terraform automation.


_NB:  Delete the `~/.ssh/config.d/ceph-digitalocean` ssh config file between deployments, lest you and ceph-deploy try connecting to nonexistant machines._

_NB:  Delete the `hosts_file` inside the terraform folder between deployments for the same reason._
* * *

[ceph]:                         http://ceph.com                                                                                 "http://ceph.com" 
[preflight]:        http://docs.ceph.com/docs/master/start/quick-start-preflight/                                   "http://docs.ceph.com/docs/master/start/quick-start-preflight/"
[storage cluster setup]:        http://docs.ceph.com/docs/master/start/quick-ceph-deploy/#                                      "http://docs.ceph.com/docs/master/start/quick-ceph-deploy/#"           
[terraform]:                    https://www.terraform.io/downloads.html                                                         "https://www.terraform.io/downloads.html"
[volume availability]:          https://www.digitalocean.com/community/tutorials/how-to-use-block-storage-on-digitalocean       "https://www.digitalocean.com/community/tutorials/how-to-use-block-storage-on-digitalocean"
