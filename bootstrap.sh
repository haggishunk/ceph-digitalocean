# upgrade & install ntp, ssh-server
apt-get update -qq > /dev/null
apt-get install -qq -y ntp
apt-get install -qq -y openssh-server

# setup user
useradd -d /home/tentacle -m tentacle
passwd tentacle
echo "tentacle ALL = (root) NOPASSWD:ALL" | tee /etc/sudoers.d/tentacle
chmod 0440 /etc/sudoers.d/tentacle
