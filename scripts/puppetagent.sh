#!/bin/bash

# Add fixed hosts entries to /etc/hosts
echo "#### Updating the /etc/hosts file with fixed data ####"
sudo cat /vagrant/files/hostsfile >> /etc/hosts

# Pull latest Puppet Agent from PE server, install, and create cert
curl -k https://172.28.128.8:8140/packages/current/install.bash | sudo bash

# Disable the Puppet Agent service starting on reboot
sudo systemctl disable puppet.service

# Stop Puppet Agent running before demo
sudo service puppet stop 
