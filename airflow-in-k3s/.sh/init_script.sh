#!/bin/bash
set -e

whoami
pwd
apt-get update
apt-get install net-tools -y
apt-get install apt-transport-https ca-certificates curl gnupg-agent software-properties-common -y

# Docker & Docker Compose 설치
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt-get update
apt-get install docker-ce docker-ce-cli containerd.io -y
wget https://github.com/docker/compose/releases/download/v2.34.0/docker-compose-linux-$(uname -m)
mv docker-compose-linux-aarch64 /usr/bin/docker-compose
chmod +x /usr/bin/docker-compose
chmod o+rw /var/run/docker.sock

# k3s install
curl -sfL https://get.k3s.io | sh -
curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
chmod 666 /etc/rancher/k3s/k3s.yaml
su - vagrant -c 'echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc; source ~/.bashrc'

# k9s install
K9S_VERSION=0.32.7
KERNEL=$(uname -s | tr A-Z a-z)
ARCH=$(uname -m)

if [ ${ARCH} == "arm64" ]; then
    ARCH_ALT=arm64
fi
if [ ${ARCH} == "aarch64" ]; then
    ARCH_ALT=arm64
fi
if [ ${ARCH} == "x86_64" ]; then
    ARCH_ALT=amd64
fi

curl --silent --location "https://github.com/derailed/k9s/releases/download/v${K9S_VERSION}/k9s_Linux_${ARCH_ALT}.tar.gz" | tar xz -C /tmp
cp /tmp/k9s /usr/local/bin
cp /tmp/k9s /usr/bin

# Airflow install
mkdir -p /opt/app/airflow
cp -v /vagrant/values.yaml /opt/app/airflow/
chown -R vagrant: /opt/app/airflow
echo "127.0.0.1 airflow.local" >> /etc/hosts