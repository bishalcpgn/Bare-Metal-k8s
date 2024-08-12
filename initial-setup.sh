
#!/bin/bash

# Enable IPv4 packet forwarding
# sysctl params required by setup, params persist across reboots
cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.ipv4.ip_forward = 1
EOF

# Apply sysctl params without reboot
sudo sysctl --system


# Temporarily disable swap until the next reboot (required by Kubernetes).
sudo swapoff -a

# Permanently disable swap by commenting out the swap entry in the /etc/fstab file.
# This prevents swap from being enabled after a reboot.
sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab




# Download the specified version of containerd using curl a
curl -LO https://github.com/containerd/containerd/releases/\
download/v1.7.19/containerd-1.7.19-linux-amd64.tar.gz


# Extract the downloaded tar.gz archive to the /usr/local directory.
# The 'C' option specifies the directory to change to before performing
# the extraction.
sudo tar -C /usr/local -xzvf containerd-1.7.19-linux-amd64.tar.gz


# Download the containerd systemd service unit file using curl 
# and save it as containerd.service.
curl -LO https://raw.githubusercontent.com/containerd/containerd/main/\
containerd.service


# Create the directory for systemd service files if it doesn't exist.
sudo mkdir -p /usr/local/lib/systemd/system







# Move the downloaded containerd.service file to the systemd service directory.
sudo mv containerd.service /usr/local/lib/systemd/system/containerd.service





# Reload the systemd manager configuration to recognize the new containerd service.
sudo systemctl daemon-reload

# Enable the containerd service to start on boot and start it immediately.
sudo systemctl enable --now containerd


# Download the runc.amd64 binary using curl.
# -L follows any redirects, and -O saves the file with its original name.
curl -LO https://github.com/opencontainers/runc/releases/download/v1.1.13/runc.amd64

# Install the runc binary to /usr/local/sbin with the correct permissions.
# -m 755 sets the permissions so that the owner can read, write, and execute,
# and others can read and execute.
sudo install -m 755 runc.amd64 /usr/local/sbin/runc







# Download the CNI plugins archive for Linux (amd64) using curl.
 curl -LO https://github.com/containernetworking/plugins/releases/download/v1.5.1/cni-plugins-linux-amd64-v1.5.1.tgz
# Create the /opt/cni/bin directory if it doesn't already exist.
# This is where the CNI plugins will be installed.
sudo mkdir -p /opt/cni/bin
# Extract the contents of the CNI plugins archive into the /opt/cni/bin directory.
# The -C option changes the directory to /opt/cni/bin before extracting the files.
# The options -xzvf are used to extract the gzip-compressed tar file, with verbose output to show the files being extracted.
 sudo tar -C /opt/cni/bin -xzvf cni-plugins-linux-amd64-v1.5.1.tgz




# Installing CRI 

VERSION="v1.31.0"
wget https://github.com/kubernetes-sigs/cri-tools/releases/download/$VERSION/crictl-$VERSION-linux-amd64.tar.gz
sudo tar zxvf crictl-$VERSION-linux-amd64.tar.gz -C /usr/local/bin
rm -f crictl-$VERSION-linux-amd64.tar.gz

cat <<EOF | sudo tee /etc/crictl.yaml
runtime-endpoint: unix:///run/containerd/containerd.sock
image-endpoint: unix:///run/containerd/containerd.sock
timeout: 2
debug: false
pull-image-on-create: false
EOF








#Kubeadm 


sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl gpg


#  sudo mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.30/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

# This overwrites any existing configuration
# in /etc/apt/sources.list.d/kubernetes.list 

echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.30/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list




#install kubeadm 

sudo apt-get update
sudo apt-get install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl






































































