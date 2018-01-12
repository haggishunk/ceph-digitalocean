gpg --keyserver keys.gnupg.net --recv-keys E84AC2C0460F3994
gpg -a --export E84AC2C0460F3994 | sudo apt-key add -
echo "deb http://download.ceph.com/debian-jewel jessie main" | sudo tee -a /etc/apt/sources.list
sudo apt-get update
sudo apt-get install ceph-deploy

