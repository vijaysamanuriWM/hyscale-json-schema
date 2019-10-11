#!/bin/bash

command_exists() {
        command -v "$@" > /dev/null 2>&1
}

if ! command_exists docker; then
	echo "docker command doesn't exists. Please install docker and execute this script again !"
	exit 1
fi

if ! command_exists kind; then
        
	echo "kind command doesn't exists. Installing..."
	# install kind
	KIND_VERSION="v0.5.1" # install k8s 1.15.3
	curl -Lo /tmp/kind https://github.com/kubernetes-sigs/kind/releases/download/v0.5.1/kind-linux-amd64
	chmod +x /tmp/kind
	sudo cp /tmp/kind /usr/bin/
else
	echo "Kind Already exists."
fi

if ! command_exists kubectl; then
	KUBECTL_VERSION="v1.15.3"
	curl -Lo /tmp/kubectl https://storage.googleapis.com/kubernetes-release/release/$KUBECTL_VERSION/bin/linux/amd64/kubectl
        chmod +x /tmp/kubectl
        sudo cp /tmp/kubectl /usr/bin/
else
	echo "kubectl already exists."
	#TODO check version compatibility and decide on reinstallation
fi
# create k8s cluster using kind
kind create cluster 

# install kubectl

# configure kubectl to the created k8s cluster
export KUBECONFIG="$(kind get kubeconfig-path)"
kubectl cluster-info
