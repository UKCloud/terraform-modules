# vCloud Director Terraform Modules

This directory contains a collection of re-usable Terraform modules for vCloud Director. They have been developed for use on Skyscape Cloud Service's vCloud infrastructure and are being provided to the Open Source community for all to make use of.

These modules have been developed using a CentOS7.2 server, deployed from a vApp Template created using Packer and the configurations in https://github.com/skyscape-cloud-services/VM-Images 

| Module | Description |
| --- | --- |
| ChefServer | Creates a stand-alone Chef Server instance for you to use to manage your infrastructure. |
| ChefCompliance | Creates a stand-alone server running the Chef Compliance software, enabling you to scan your infrastructure and ensure compliance in your deployments. |
| PowerDNS | Deploys a server running PowerDNS, which Terraform can then use for Dynamic DNS updates. |

To make use of these modules, you need to first configure the vcd provider:
```
# Configure the VMware vCloud Director Provider
provider "vcd" {
    user                 = "${var.vcd_userid}"
    org                  = "${var.vcd_org}"
    password             = "${var.vcd_pass}"
    vdc                  = "${var.vcd_vdc}"
    url                  = "https://api.vcd.portal.skyscapecloud.com/api"
    allow_unverified_ssl = "false"
    maxRetryTimeout      = 300
}
```


----------
## ChefServer Module
See the variables.tf file for all the parameters that can be passed into the module.

This module uses SSH Keys to login to the server and makes use of VMWare's GuestCustomisation script to deploy the specified public key. The vApp Template  specified should have vmware tools already installed.
```
module "chef_server" {
	source          = "github.com/skyscape-cloud-services/terraform-modules//vcloud/ChefServer"

    catalog         = "GoldImages"
    vapp_template   = "centos72"
	network_name    = "Management Network"
	int_ip          = "10.10.0.50"

	ssh_key_pub     = "${file("~/.ssh/${var.ssh_userid}.pub")}"
	ssh_key_private = "${file("~/.ssh/${var.ssh_userid}.private")}"

	chef_admin_userid     = "admin" 
	chef_admin_firstname  = "Admin" 
	chef_admin_lastname   = "User" 
	chef_admin_email      = "admin@example.com" 
	chef_admin_password   = "${var.chef_admin_password}" 
	chef_org_short        = "example" 
	chef_org_full         = "Example Organisation" 
}
```

----------

License
-------
Copyright 2016 Skyscape Cloud Services

Licensed under the Apache License, Version 2.0 (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.
