variable "vcd_org"        {}
variable "vcd_userid"     {}
variable "vcd_pass"       {}
variable "vcd_api_url"    { default = "https://api.vcd.portal.skyscapecloud.com/api" }
variable "vcd_timeout"    { default = 300 }

variable "catalog"        { default = "DevOps" }
variable "vapp_template"  { default = "centos71" }

variable "hostname"       { default = "powerdns01" }
variable "network_name"   { default = "Management Network" }
variable "cpu_count"      { default = "1" }
variable "memory"         { default = "1024" }

variable "edge_gateway"   { default = "Edge Gateway Name" }
variable "int_ip"         { default = "10.10.0.51" }

variable "ssh_userid"     { default = "root" }
variable "ssh_user_home"  { default = "/root"}
variable "ssh_key_pub"    {}
variable "ssh_key_private" {}

variable "bastion_host"   {}
variable "bastion_userid" { default = "root" }
variable "bastion_key_private" {}

variable "mysql_powerdns_password" { default = "P@ssword123#" }