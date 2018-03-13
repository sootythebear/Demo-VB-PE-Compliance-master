# puppet-demo

## Description

This module is to show some of the basic tenants of Puppet DSL. All examples are run standalone, i.e. Open Source via **puppet apply**

Stored (under the V_presentation folder) in this repo is a brief PPT to use to give an overview of Puppet before the demo. The suggested demo agenda would be:

1. Present the slides
1. Quick Q&A
1. Show demo 
  1. Start with `web` (init.pp), show web page
    1. Run `puppet apply --modulepath /tmp/module -e "include web"`
    1. Provide overview of the `init.pp` manifest file
  1. Follow with changing the file (index.html), then run puppet apply against the `web` class again
    1. Use `vi` to edit the file `web/files/index.html`
    1. Run `puppet apply --modulepath /tmp/module -e "include web"` again
    1. Show that only the content is changed during `puppet apply`
  1. Execute the `removal` class with `web::remove`
    1. Run `puppet apply --modulepath /tmp/module -e "include web::remove"`
    1. Provide overview of the `remove.pp` manifest file, show ordering requirement
  1. Perform `web::template`, show web page
    1. Run `puppet apply --modulepath /tmp/module -e "include web::template"`
    1. Provide overview of the `template.pp` file, along with template (`web/templates/index.html.erb`) file
  1. Go to the Forge and search for the apache module. Explain the community, additions in the apache module etc.
    1. Download the apache module: `puppet module install puppetlabs-apache --modulepath /tmp/module`
    1. Remove the existing web applicate with `web::remove`
    1. Install the apache module: `puppet apply --modulepath /tmp/module -e "include apache"`
    1. Review web page again
1. Final Q&A

## Environment

A manually created Server requires the following (**Note:** using Vagrant will perform these tasks):

1. OS - Linux, either RHEL or Debian flavour
1. Puppet Agent installed (present RHEL 7 command is: `rpm -Uvh https://yum.puppetlabs.com/puppetlabs-release-pc1-el-7.noarch.rpm`)
1. Proxy environment variables configured
1. The git package installed


## Setup

### Automated 
(**Note:** requires VirtualBox and Vagrant - w/ the `vagrant-vbguest` and `vagrant-proxyconf` plugins installed):

1. Perform a `git clone` of this repo.

1. Change folder into the `puppet-demo` folder

1. Run `vagrant up puppetdemo`
(**Note:** Vagrant will create a Centos 7.2 box w/ a DHCP 15/16 IP address and the proxy/yum details configured, then will provision the OS with a Puppet Agent, and then move this repo under `/tmp/module/web`. Not being able to mount the `/vagrant` folder will result in a failure.) 

### Manual 
(**Note:** assumes you will manually install the Puppet Agent and Git packages):

1. Provision a server running a RHEL variant.

1. Create a new directory where the module will be cloned to. For example: **/tmp/module**

1. Change directory into the new directory.

1. Git clone this repo.

1. Rename the "puppet-demo" directory name to "web" i.e. with: **mv puppet-demo web**

1. Obtain the Puppet **stdlib** from the Forge
```
puppet module install puppetlabs-stdlib --modulepath /tmp/module
```

**Additional step: (for both automated and manual setups)** Ascertain the public IP address for the web site. Alter the `manifests/init.pp` and `manifests/template.pp` files accordingly to show the Facter result correctly.

## Usage 

Basic web appliance:
```
puppet apply --modulepath /tmp/module -e "include web"
```
To remove the web appliance:
```
puppet apply --modulepath /tmp/module -e "include web::remove"
```
To show template usage:
```
puppet apply --modulepath /tmp/module -e "include web::template"
```
