#!/bin/bash

# Add fixed hosts entries to /etc/hosts
echo "#### Updating the /etc/hosts file with fixed data ####"
sudo cat /vagrant/files/hostsfile >> /etc/hosts

# Unpack Puppet Enterprise TAR file into /tmp
sudo tar xf /vagrant/files/pe-latest.tar.gz -C /tmp

# Install PE
sudo /tmp/puppet-enterprise*/puppet-enterprise-installer -c /vagrant/files/pe.conf

# Install dos2unix command to address any DOS/Git conversion issues, epel-release to install jq
sudo yum -y install dos2unix epel-release
sudo yum -y install jq

# Copy wrapper_puppet_agent script to /tmp
sudo cp /vagrant/scripts/wrapper_puppet_agent.sh /tmp/wrapper_puppet_agent.sh

# Convert wrapper_puppet_agent script to Unix
sudo dos2unix /tmp/wrapper_puppet_agent.sh

# Add execute to the Puppet Agent wrapper
sudo chmod +x /tmp/wrapper_puppet_agent.sh

# Run wrapper script to manage Puppet Agent output
sudo /tmp/wrapper_puppet_agent.sh

# Unpack the script and JSON template files - absolute path
sudo tar xvPf /vagrant/files/groups.tar.gz

# Unpack the web classes under Puppet production environment - absolute path
sudo tar xvPf /vagrant/files/web_module.tar.gz
