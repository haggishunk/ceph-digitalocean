# Ceph Cluster on Digital Ocean
(currently just the instance provisioning & configuration)

### Purpose

[Ceph][] is a cool open-source cluster storage solution that features device, block & object storage.

### Requirements

* [OpenSSH 7.3p1][] or later to support `Include` directive in ssh_config file.

* [DigitalOcean][] account

* [ssh-agent][]

### Usage

1. Install [Terraform][]

2. Clone the repo
```
git clone https://github.com:haggishunk/ceph-digitalocean.git
cd ceph-digitalocean/terraform
```

3. Add an include statment to the head of your SSH config file (~/.ssh/config)
```
include config.d/*
```

4. Create an SSH config subdirectory
```
mkdir ~/.ssh/config.d
```

5. Make changes to terraform variables file

* `terraform.tfvars`
  * `ssh_id:` change to your DigitalOcean SSH key md5 fingerprint or [ID][]
  * `instances:` change to desired number of nodes _(optional)_
  * `do_region:` change to desired DigitalOcean instance region.  Make sure to select a region with [volume availability][] _(optional)_
  * `size_vol:` change to desired volume size _(optional)_

2. Export your DigitalOcean token as an environment variable:
```
$ export DIGITALOCEAN_TOKEN="your-long-token-string-here"
```

3. Initialize ssh-agent and add the SSH key that corresponds to the one you specified above:
```
$ eval $(ssh-agent)
$ ssh-add /path/to/your/id_rsa
```

6. Initialize
```
terraform init
```

7. Plan
```
terraform plan -out plan
```

8. Deploy 
```
terraform apply plan
```

9. When the deployment is complete you should be able to SSH into the node names listed in Terraform's output directly from your local machine, for example:
```
user@home:~$ ssh ceph-admin -t 'exec bash'
cephalus@ceph-admin:~$ 
```

10. and from the admin node to the worker nodes, like so:
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
[ssh-agent]:                    https://linux.die.net/man/1/ssh-agent
[id]:                           https://www.digitalocean.com/community/tutorials/how-to-use-doctl-the-official-digitalocean-command-line-client
