# Vagrant 를 활용한 ollama 로컬 환경 구축
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
    vb.name = "vagrant-net9-ubuntu24.04"
  end

  config.vm.define :ubuntu do |host|
    host.vm.box = "net9/ubuntu-24.04-arm64"
    host.vm.box_version = "1.1"
    host.vm.hostname = "ubuntu"
    host.vm.network :private_network, ip: "192.168.5.100"
    host.vm.network :forwarded_port, guest: 11434, host:11434
    host.vm.network :forwarded_port, guest: 8080, host:8080
    host.vm.network :forwarded_port, guest: 8000, host:8000
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
## 9. Disk 증설
```bash
sudo su - 

# Disk 용량 증설
parted /dev/sda print
parted /dev/sda resizepart 3 100%
pvresize /dev/sda3
vgdisplay
lvdisplay
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
resize2fs /dev/ubuntu-vg/ubuntu-lv
```

`Fix/Ingnore?` 나올 시 `Fix` 입력 후 `Enter`
## 10. Ollama 설치
https://github.com/mythrantic/ollama-docker <br>
필요한 파일<br>
  * Dockerfile
  * docker-compose.yaml
  * src/**
```bash
cd /vagrant/docker/ollama
docker-compose up -d
```
## 11. Ollama 사용
http://localhost:8080<br>
모델: gemma3:4b<br>
`설정 > 관리자 설정 > 모델 접속 후 다운로드`<br>
이후 다운로드 받은 모델을 이용해서 ChatGPT와 마찬가지로 명령어 실행 가능