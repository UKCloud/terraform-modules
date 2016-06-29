variable "vcd_org"        {}
variable "vcd_userid"     {}
variable "vcd_pass"       {}
variable "vcd_api_url"    { default = "https://api.vcd.portal.skyscapecloud.com/api" }
variable "vcd_timeout"    { default = 300 }

variable "catalog"        { default = "DevOps" }
variable "vapp_template"  { default = "centos71" }

variable "hostname"       { default = "compliance01" }
variable "network_name"   { default = "Management Network" }
variable "cpu_count"      { default = "2" }
variable "memory"         { default = "4096" }

variable "edge_gateway"   { default = "Edge Gateway Name" }
variable "int_ip"         { default = "192.168.100.100" }
variable "ext_ip"         { default = "10.20.30.40" }

variable "ssh_userid"     { default = "root" }
variable "ssh_user_home"  { default = "/root"}
variable "ssh_key_pub"    {}
variable "ssh_key_private" {}

variable "bastion_host"   {}
variable "bastion_userid" { default = "root" }
variable "bastion_key_private" {}

variable "compliance_download"  { default = "https://packages.chef.io/stable/el/7/chef-compliance-1.1.23-1.el7.x86_64.rpm" }

#variable "chef_admin_userid"    { default = "administrator" }
#variable "chef_admin_firstname" { default = "System" }
#variable "chef_admin_lastname"  { default = "Administrator" }
#variable "chef_admin_email"     { default = "admin@example.com" }
#variable "chef_admin_password"  { default = "secret" }
#variable "chef_org_short"       { default = "example" }
#variable "chef_org_full"        { default = "Example Organisation" }