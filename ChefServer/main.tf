# Configure the VMware vCloud Director Provider
provider "vcd" {
    user            = "${var.vcd_userid}"
    org             = "${var.vcd_org}"
    password        = "${var.vcd_pass}"
    url             = "${var.vcd_api_url}"
    maxRetryTimeout = "${var.vcd_timeout}"
}

resource "template_file" "knife" {
    template = "${file("${path.module}/knife.tpl")}"

    vars {
        node_name = "${var.chef_admin_userid}"
        validation_client_name = "${var.chef_org_short}-validator"
        chef_server_url = "https://${var.ext_ip}/organizations/${var.chef_org_short}"
    }
}
resource "vcd_vapp" "chefserver" {
    name          = "${var.hostname}"
    catalog_name  = "${var.catalog}"
    template_name = "${var.vapp_template}"
    memory        = "${var.memory}"
    cpus          = "${var.cpu_count}"
    network_name  = "${var.network_name}"
    ip            = "${var.int_ip}"

    initscript    = "mkdir -p ${var.ssh_user_home}/.ssh; echo \"${var.ssh_key_pub}\" >> ${var.ssh_user_home}/.ssh/authorized_keys; chmod -R go-rwx ${var.ssh_user_home}/.ssh; restorecon -Rv ${var.ssh_user_home}/.ssh"

    connection {
        host = "${var.int_ip}"
        user = "${var.ssh_userid}"
        private_key = "${var.ssh_key_private}"

        bastion_host = "${var.bastion_host}"
        bastion_user = "${var.bastion_userid}"
        bastion_private_key = "${var.bastion_key_private}"
    }

    provisioner "remote-exec" {
        inline = [
        "yum -y install wget",
        "cd /tmp",
        "wget ${var.chef_download}",
        "rpm -Uvh /tmp/chef-server-core*",
        "chef-server-ctl reconfigure",
        "mkdir -p ${var.ssh_user_home}/.chef",
        "echo '${template_file.knife.rendered}' > ${var.ssh_user_home}/.chef/knife.rb",
        "chef-server-ctl user-create ${var.chef_admin_userid} ${var.chef_admin_firstname} ${var.chef_admin_lastname} ${var.chef_admin_email} '${var.chef_admin_password}' --filename ${var.ssh_user_home}/.chef/${var.chef_admin_userid}.pem",
        "chef-server-ctl org-create ${var.chef_org_short} '${var.chef_org_full}' --association_user ${var.chef_admin_userid} --filename ${var.ssh_user_home}/.chef/${var.chef_org_short}-validator.pem",
        "chef-server-ctl install chef-manage",
        "chef-server-ctl reconfigure",
        "chef-manage-ctl reconfigure",
        "chef-server-ctl install opscode-reporting",
        "chef-server-ctl reconfigure",
        "opscode-reporting-ctl reconfigure",
        "cd ${var.ssh_user_home}",
        "tar zcvf ${var.ssh_user_home}/chefconfig.tar.gz .chef/*"
        ]
    }
}

# Inbound HTTPS to the Chef server
resource "vcd_dnat" "chefserver-https" {

    edge_gateway  = "${var.edge_gateway}"
    external_ip   = "${var.ext_ip}"
    port          = 443
    internal_ip   = "${vcd_vapp.chefserver.ip}"
}

resource "vcd_firewall_rules" "chefserver-fw" {
    edge_gateway   = "${var.edge_gateway}"
    default_action = "drop"

    rule {
        description      = "allow-chefserver-https"
        policy           = "allow"
        protocol         = "tcp"
        destination_port = "443"
        destination_ip   = "${var.ext_ip}"
        source_port      = "any"
        source_ip        = "any"
    }
}

