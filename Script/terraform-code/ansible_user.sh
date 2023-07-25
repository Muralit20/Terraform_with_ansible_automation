#! /bin/bash
sudo apt-get update
sudo apt  install awscli -y
sudo apt install python-minimal -y
sudo useradd -p $(openssl passwd -1 admin) ansible
sudo mkdir /home/ansible
sudo chown -R ansible:ansible /home/ansible/
sudo useradd apache
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i '$ a ansible ALL=(ALL) NOPASSWD:ALL' /etc/sudoers
sudo service ssh restart
