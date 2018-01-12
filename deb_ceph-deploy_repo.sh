gpg --recv-keys E84AC2C0460F3994
gpg -a --export E84AC2C0460F3994 | apt-key add -
echo "deb http://download.ceph.com/debian-jewel jessie main" >> /etc/apt/sources.list
apt update
apt-get install ceph-deploy

