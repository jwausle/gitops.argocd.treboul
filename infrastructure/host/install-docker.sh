
apt-get install ca-certificates curl

apt-get install uidmap
apt-get install -y dbus-user-session
apt-get install -y docker-ce-rootless-extras # to

apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
systemctl disable --now docker.service docker.socket

dockerd-rootless-setuptool.sh install

# https://docs.docker.com/engine/security/rootless/#exposing-privileged-ports
# --privileged: docker: Cannot connect to the Docker daemon at unix:///var/run/docker.sock. Is the docker daemon running?.
setcap cap_net_bind_service=ep $(which rootlesskit)
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
# ... no success 443 still not exposed

# https://medium.com/@gokhanefendi/how-to-reset-iptables-to-default-d60ca88f6e5e
# IPv6 - not execute

# IPv4 - reset to get access to 80 and 443
## set default policies to let everything in
iptables --policy INPUT   ACCEPT;
iptables --policy OUTPUT  ACCEPT;
iptables --policy FORWARD ACCEPT;

## start fresh
iptables -Z; # zero counters
iptables -F; # flush (delete) rules
iptables -X; # delete all extra chains

# Install kubectl
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g docker -m 0755 kubectl /usr/local/bin/kubectl

