# Vagrant 환경을 이용한 로컬 성능테스트 환경 구성
## 1. Vagrant install
```bash
brew install vagrant
```
## 2. Vagrant 초기화
```bash
vagrant init
```
## 3. Vagrantfile 작성
```text
Vagrant.configure("2") do |config|
  config.vm.synced_folder ".", "/vagrant"
  config.disksize.size = '50GB'

  config.vm.provider :virtualbox do |vb|
    vb.name = "performance-test-in-vagrant"
  end

  config.vm.define :ubuntu do |host|
    host.vm.box = "net9/ubuntu-24.04-arm64"
    host.vm.box_version = "1.1"
    host.vm.hostname = "ubuntu"
    host.vm.network :private_network, ip: "192.168.5.101"
    host.vm.network :forwarded_port, guest: 8089, host:8089
    host.vm.network :forwarded_port, guest: 19999, host:19999
    host.vm.network :forwarded_port, guest: 443, host:443
    host.vm.network :forwarded_port, guest: 80, host:80
    host.vm.provision :shell, path: "./.sh/init_script.sh"
    host.vm.provider "virtualbox" do |vb|
      vb.memory = 8192
      vb.cpus = 4
    end
  end
end
```
## 4. init script 작성
```shell
#!/bin/bash
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
# Disk 용량 증설
parted /dev/sda print
parted /dev/sda resizepart 3 100%
pvresize /dev/sda3
vgdisplay
lvdisplay
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
resize2fs /dev/ubuntu-vg/ubuntu-lv
```
## 5. Vagrant up
```bash
vagrant up
```
## 6. Vagrant 환경 접속
```bash
vagrant ssh
```
## 7. Vagrant stop
```bash
vagrant halt
```
## 8. Vagrant 삭제
```bash
vagrant destroy
```
## 9. fastpi 구동
```bash
cd /vagrant/docker/fastapi
docker build -t fastapi .
docker-compose up -d
```
## 10. locust 구동
```bash
cd /vagrant/docker/locust
docker-compose up -d
```
## 11. netdata 구동
```bash
cd /vagrant/docker/netdata
docker-compose up -d
```
## 12. 로컬 성능테스트
1. locust 접속 (http://localhost:8089)
2. 아래 내용으로 load test 시작
    - User: 10
    - Ramp up: 10
    - Host: http://192.168.5.101
    - Time: 5m
3. netdata 접속 (http://localhost:19999)
4. System 및 Container Metric 확인