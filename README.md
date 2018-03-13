# Demo-VB-PE-Compliance

This repo spins up a Puppet Enterprise environment, within VirtualBox via Vagrant, which will then be used show Puppet's compliance features (see `Script` section of this Readme).

The repo:
 * creates a Puppet Enterprise instance on Centos 7
 * creates a Puppet Client instance on Centos 7
 * will sign the client certificate so that the Puppet stack is ready for immediate use
 * creates a new classifcation, module and adds the Puppet Client instance to classification and class
 * stops the Puppet Agent on the Puppet Client, so demo script can be performed in order

## Demo Setup

This demo utilises `VirtualBox` and `Vagrant` to build and provision the environment. This software will need to be installed and configured before the demo can be run. The ability to 'sync' the present working folder, and download software over the Internet, requires that the Vagrant plug-ins - `vagrant-share`, `vagrant-vbguest` and `vagrant-proxyconf` have already been installed (use: `vagrant plugin install <plugin>` in install as required). The setup script checks for these plug-ins and that Vagrant is version 1.9.2, or above (required to resolve a private network interface issue with RH Linux versions).

This repo provides the `Vagrantfile` and provisioning scripts required. The environment needs to know the FQDN/IP addresses for each server, and this is controlled via the `Vagrantfile`, provisioning scripts, and a file called `hostsfile`. The repo at present has the domain hard coded to `local.net` - change this in the `Vagrantfile` and `hostsfile` accordingly, but all are on a private network. 

The environment requires a lot of physical memory, as the Puppet servers require at least >2GB of memory - this demo should only be run on PCs with more than `4GB` of memory installed.

**Puppet Enterprise**

You will need to obtain the **Puppet Enterprise TAR** bundle. This file needs to be stored in the `files` folder in this Git repo. The file name in `files` is expected to be `pe-latest.tar.gz`. 

**Setup the environment**

    1. `Git clone` this GitHub repo.
    2. Change directory into the `Demo_VB_PE_Compliance` folder
    3. Copy the `pe-latest.tar.gz` under the `files` folder 
    4. Run the command: `./setup_demo.sh`
Note: the setup takes about 20-25 minutes to configure, expect some additional time if the Centos 7.3 image needs to be initially downloaded.

## Script

### Puppet Compliance overview

Puppet's existing compliance model is built on monitoring the modules, classes and resources updated by the Puppet Agent. If changes occur during the Puppet Agent run against the existing DSL code, these are reported back to the Puppet Enterprise and reported; either as `intentional` or `corrective` changes. These changes are then highlighted with the PE UI. This demo runs through how the PE Master UI exposes and reports the changes. **Note:** Puppet has a roadmap to add functionality around **compliance**, this demo will need to be updated accordingly as the functionality is released via upcomming releases.

### Pre-demo validation:

1. Access the Puppet Master UI via `https://172.28.128.8`
2. Login via `admin/1qaz2wsx` (default password)
3. Goto `Nodes (left-hand menu) -> Classification`, expand `Production environment` - confirm `Compliance Group` is listed
4. Click on `Compliance Group -> Rules` - ensure the Puppet Client is listed under the `nodes pinned to this group` section
5. Moving tab to `Classes` - ensure the `web` class is shown
6. At this stage, the Puppet Client will NOT be listed under `Nodes -> Inventory` (though the client has had its cert signed)

### Simplistic Demo (suggestion):

#### Setup:
**Key: PM = Puppet Master, PA = Puppet Agent**

1. **Bash shell(PM):** Log into the Puppet Master (i.e. vagrant ssh demopuppetmaster), then `sudo bash -l`
2. **Bash shell(PA):** Log into the Puppet client (i.e. vagrant ssh demopuppetagent), then `sudo bash -l`
3. **Web browser(PM):** Log into the Puppet Master UI
4. **Web browser(PA):** Open new tab and goto: `http://172.28.128.9` - it should fail

#### Steps:

1. **Bash shell(PA):** On Puppet Client, run `puppet agent -t` (the first run will be lengthy, configuring mcollective etc., but at the end the web class should be seen).
2. **Web browser(PA):** Refresh the tab for the Puppet Client - you should now see `Hello world`
3. **Web browser(PM):** Within the Puppet Master UI, goto `Configuration -> Overview`, show that the last Puppet Client run had `intentional changes` (run status color should be "blue")
4. **Bash shell(PA):** On Puppet client, edit the `index.html` file via `vi /var/www/html/index.html`, add text to the `Hello world` string; save file
5. **Web browser(PA):** Refresh the tab for the Puppet Client - new text should be shown
6. **Bash shell(PA):** On Puppet client, run `puppet agent -t` - the index.html file should be reverted back to original text
7. **Web browser(PA):** Refresh the tab for the Puppet Client - `Hello world` should be shown
8. **Web browser(PM):** Within the Puppet Master UI, refresh the tab (or go back to `Configuration -> Overview`), show that the last Puppet Client run had corrective changes (run status color should be "yellow")
9. **Web browser(PM):** Within the Puppet Master UI, on the line showing the run status of the Puppet client, hit the `Events` hyperlink - this will take you to a screen showing the corrective change, highlight the line entry.
10. **Web browser(PM):** Within the Puppet Master UI, return back to `Configuration -> Overview`, on the same line showing the run status of the Puppet client, hit the `view node graph` hyperlink - this will take you to the node graph screen for the last run, the corrective change will be highlighed in "yellow"
11. **Bash shell(PA):** On the Puppet client, run `puppet agent -t` - no changes should be made
12. **Web browser(PM):** Within the Puppet Master UI, return back to `Configuration -> Overview` - the last run status of the Puppet Client should now be `unchanged` (the run status color should be "green")
13. **Bash shell(PM):** On Puppet Master, edit the `index.html` file within the module via `vi /etc/puppetlabs/code/environments/production/modules/web/files/index.html`, add text to the `Hello world` string; save the file
14. **Bash shell(PA):** On Puppet client, run `puppet agent -t` - the updated change should be seen in the output
15. **Web browser(PA):** Refresh the tab for the Puppet Client - the new text should be shown
16. **Web browser(PM):** Within the Puppet Master UI, refresh the `Configuration -> Overview` page, highlight again that the run status has changed to `intentional change` for the last Puppet Client run, go to the `Events` hyperlink against the line entry, highlight the `intentional change`, revert back to `Overview`, and show the `node graph` as required.
17. **Web browser(PM):** Within the Puppet Master UI, go to `Nodes` (on left hand menu), within `Inventory` list, pick the hyperlink for the `Puppet Client`; on the new page for the Puppet Client, hit the tab called `Reports` - this will show the full history of Puppet runs on the Puppet Client including whether changes were `intentional` or `corrective`


## Known Issues
  * The Puppet Agent command returns an `exit code of 2` if changes were successfully made, however some software requires an `exit code of 0`. The `wrapper_puppet_agent.sh` script was created to manage this scenario. 
  * Any flat ASCII file copied over runs the risk of being 'spammed' going between DOS and *nix - dos2unix is installed and run to mitigate.
