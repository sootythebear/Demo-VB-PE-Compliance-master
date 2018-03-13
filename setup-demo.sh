#!/bin/bash

# Test that Vagrant version is greater than 1.9.1
VERSION=`vagrant --version | cut -f2 -d" " | tr -d "."`

if test $VERSION -lt 192
then
   echo "Version of Vagrant needs to be 1.9.2 or greater!!!"
   echo "Exiting...."
   exit 99

fi

# Test to ensure that Vagrant plugins are available
echo "#### Checking that required Vagrant plugins are installed. ####"
vagrant plugin list | grep vagrant-vbguest
GUEST=`echo $?`
vagrant plugin list | grep vagrant-share
SHARE=`echo $?`
vagrant plugin list | grep vagrant-proxyconf
PROXYCONF=`echo $?`

TOTAL=`expr $GUEST + $SHARE + $PROXYCONF`

if test $TOTAL -gt 0
then
   echo "#### Missing Vagrant plugins, ensure vagrant-vbguest and vagrant-share are installed...."
   exit 2
fi

# Spin up Puppet Master
echo "#### Bringing up Puppet Master ####"
vagrant up demopuppetmaster

# Spin up initial Puppet Agent box
echo "#### Bringing up initial Puppet Agent ####"
vagrant up demopuppetagent

# Sign the Puppet Agent cert on Puppet Master
echo "#### Signing Puppet Agent cert on Puppet Master ####"
vagrant ssh demopuppetmaster -c 'sudo /opt/puppetlabs/bin/puppet cert sign demopuppetagent.local.net'

# Create classification, add module and Puppet Agent on Puppet Master
echo "#### Adding classification, module and Puppet Agent to classification on Puppet Master ####"
vagrant ssh demopuppetmaster -c 'sudo /tmp/scripts/PE_group.sh 172.28.128.8 demopuppetagent.local.net 1qaz2wsx'

# Run Puppet Agent on Master to finalize install
vagrant ssh demopuppetmaster -c 'sudo /opt/puppetlabs/bin/puppet agent -t'

# Stop and disable the Puppet Agent on the Master - to stop runs during the demo
vagrant ssh demopuppetmaster -c 'sudo systemctl disable puppet.service'
vagrant ssh demopuppetmaster -c 'sudo service puppet stop'
