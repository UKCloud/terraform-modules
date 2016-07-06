# Templated knife.rb file to be deployed to the server
resource "template_file" "knife" {
    template = "${file("${path.module}/knife.tpl")}"

    vars {
        node_name = "${var.chef_admin_userid}"
        validation_client_name = "${var.chef_org_short}-validator"
        chef_server_url = "https://${var.hostname}/organizations/${var.chef_org_short}"
    }
}

# Create a vApp for the Chef Server
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
