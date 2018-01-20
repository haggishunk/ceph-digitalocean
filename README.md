# Ceph Cluster on Digital Ocean
(currently just the instance provisioning & configuration)

### Purpose

[Ceph][] is a cool open-source cluster storage solution that features device, block & object storage.

### Requirements

* [OpenSSH 7.3p1][] or later to support `Include` directive in ssh_config file.

* [DigitalOcean][] account

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

* `terraform.tfvars`
  * `ssh_id:` change to your DigitalOcean SSH key md5 fingerprint
  * `instances:` change to desired number of nodes _(optional)_
  * `do_region:` change to desired DigitalOcean instance region.  Make sure to select a region with [volume availability][] _(optional)_
  * `size_vol:` change to desired volume size _(optional)_

* `provider.tf`
  * `token:` change file path to location of your DigitalOcean token string

* `instances.tf`
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
user@home:~$ ssh ceph-admin -t 'exec bash'
cephalus@ceph-admin:~$ 
```

and from the admin node to the worker nodes, like so:
```
cephalus@ceph-admin:~$ ssh ceph-1 -t 'exec bash'
tentacle@ceph-1:~$
```

You are now complete with the `ceph-deploy` [preflight][] instructions and you can begin [storage cluster setup][].  Future developments to this module will implement these steps in Terraform automation.

Or alternatively, check out my [blog post][] for step-by-step instructions to stand up a Ceph object storage cluster on your new DO droplets.

* * *

[ceph]:                         http://ceph.com
[openssh 7.3p1]:                https://www.openssh.com/txt/release-7.3
[digitalocean]:                 https://cloud.digitalocean.com
[preflight]:        http://docs.ceph.com/docs/master/start/quick-start-preflight/
[storage cluster setup]:        http://docs.ceph.com/docs/master/start/quick-ceph-deploy/#
[terraform]:                    https://www.terraform.io/downloads.html
[volume availability]:          https://www.digitalocean.com/community/tutorials/how-to-use-block-storage-on-digitalocean
[blog post]:                    http://blog.pantageo.us/ceph-storage-cluster-on-digital-ocean-using-terraform-part-3.html
