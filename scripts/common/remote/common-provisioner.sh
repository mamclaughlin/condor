#!/bin/bash

set -euxo

INSTANCE_METADATA=$(curl --silent http://169.254.169.254/v1.json)
PRIVATE_IP=$(echo $INSTANCE_METADATA | jq -r .interfaces[1].ipv4.address)
CONTAINERD_RELEASE="1.2.10-3"
DOCKER_RELEASE="5:19.03.4~3-0~debian-$(lsb_release -cs)"

pre_dependencies(){
	cat <<-EOF > /etc/sysctl.d/k8s.conf
		net.bridge.bridge-nf-call-ip6tables = 1
		net.bridge.bridge-nf-call-iptables = 1
		EOF

	sysctl --system

	apt -y update
	apt -y upgrade

	apt -y install jq gnupg2 iptables arptables ebtables

	update-alternatives --set iptables /usr/sbin/iptables-legacy
	update-alternatives --set ip6tables /usr/sbin/ip6tables-legacy
	update-alternatives --set arptables /usr/sbin/arptables-legacy
	update-alternatives --set ebtables /usr/sbin/ebtables-legacy
}

network_config(){
	cat <<-EOF > /etc/systemd/network/ens3.network
		[Match]
		Name=ens3

		[Network]
		DHCP=yes
		EOF

	cat <<-EOF > /etc/systemd/network/ens3.network
		[Match]
		Name=ens7

		[Network]
		Address=$PRIVATE_IP
		EOF

	systemctl enable systemd-networkd systemd-resolved
	systemctl restart systemd-networkd systemd-resolved
}

install_k8(){
	curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

	cat <<-EOF /etc/apt/sources.list.d/kubernetes.list
		deb https://apt.kubernetes.io/ kubernetes-xenial main
		EOF

	apt -y update
	apt -y install kubelet kubeadm kubectl
	apt-mark hold kubelet kubeadm kubectl

	cat <<-EOF /etc/default/kubelet
		KUBELET_EXTRA_ARGS="--cloud-provider=external"
		EOF
}

install_docker(){
	apt -y update
	apt-transport-https ca-certificates curl gnupg2 software-properties-common

	curl -fsSL https://download.docker.com/linux/debian/gpg | apt-key add -

	cat <<-EOF /etc/apt/sources.list.d/docker.list
		deb [arch=amd64] https://download.docker.com/linux/debian $(lsb_release -cs) stable
		EOF

	apt -y update
	apt -y install containerd.io=$CONTAINERD_RELEASE docker-ce=$DOCKER_RELEASE docker-ce-cli=$DOCKER_RELEASE

	cat > /etc/docker/daemon.json <<-EOF
		{
		  "exec-opts": ["native.cgroupdriver=systemd"],
		  "log-driver": "json-file",
		  "log-opts": {
		    "max-size": "100m"
		  },
		  "storage-driver": "overlay2"
		}
		EOF

	mkdir -p /etc/systemd/system/docker.service.d

	systemctl daemon-reload
	systemctl enable docker
	systemctl restart docker
}

main(){
	pre_dependencies
	network_config
	install_k8
	install_docker
}

main