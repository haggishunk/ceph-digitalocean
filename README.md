# Ceph Cluster on Digital Ocean
(currently just the instance provisioning & configuration)

### Purpose

[Ceph][] is a cool open-source cluster storage solution that features device, block & object storage.

### Usage

Install [Terraform][]

Clone the repo
```
git clone https://github.com:haggishunk/ceph-digitalocean.git
cd ceph-digitalocean
```

Make changes to terraform config files

`terraform.tfvars`
* `ssh_id:` change to your DigitalOcean SSH key md5 fingerprint
* `instances:` change to desired number of nodes, min 3 _(optional)_
* `do_region:` change to desired DigitalOcean instance region, select a region with [volume availability][] _(optional)_

`provider.tf`
* `token:` change file path to location of your DigitalOcean token string

`instances.tf`
* `connection - private_key:` ensure private key file matches fingerprint specified with `ssh_id` above

Initialize
```
terraform init
```

Plan
```
terraform plan
```

Deploy
```
terraform apply
```

Respond with 'yes' at the prompt.

When the deployment is complete you should be able to SSH into the node names listed.
```
ssh ceph-1
```

You are now complete with the `ceph-deploy` [preflight][] instructions and you can begin [storage cluster setup][].  Future developments to this module will implement these steps in Terraform automation.

* * *

[ceph]:                         http://ceph.com                                                                                 "http://ceph.com" 
[preflight]:        http://docs.ceph.com/docs/master/start/quick-start-preflight/                                   "http://docs.ceph.com/docs/master/start/quick-start-preflight/"
[storage cluster setup]:        http://docs.ceph.com/docs/master/start/quick-ceph-deploy/#                                      "http://docs.ceph.com/docs/master/start/quick-ceph-deploy/#"           
[terraform]:                    https://www.terraform.io/downloads.html                                                         "https://www.terraform.io/downloads.html"
[volume availability]:          https://www.digitalocean.com/community/tutorials/how-to-use-block-storage-on-digitalocean       "https://www.digitalocean.com/community/tutorials/how-to-use-block-storage-on-digitalocean"