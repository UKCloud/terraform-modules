# Configure the VMware vCloud Director Provider
provider "vcd" {
    user            = "${var.vcd_userid}"
    org             = "${var.vcd_org}"
    password        = "${var.vcd_pass}"
    url             = "${var.vcd_api_url}"
    maxRetryTimeout = "${var.vcd_timeout}"
}

resource "template_file" "schema_sql" {
    template = "${file("${path.module}/schema.sql")}"

    vars {
        mysql_password = "${var.mysql_powerdns_password}"
    }
}

resource "template_file" "pdns_conf" {
    template = "${file("${path.module}/pdns.conf")}"

    vars {
        mysql_password = "${var.mysql_powerdns_password}"
    }
}

resource "vcd_vapp" "powerdns" {
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
        "yum -y install epel-release",
        "yum -y install mariadb-server mariadb",
        "systemctl enable mariadb.service",
        "systemctl start mariadb.service",
        "echo '${template_file.schema_sql.rendered}' > ${var.ssh_user_home}/schema.sql",
        "cat ${var.ssh_user_home}/schema.sql | mysql",
        "yum -y install pdns pdns-backend-mysql",
        "echo '${template_file.pdns_conf.rendered}' > /etc/pdns/pdns.conf",
        "systemctl enable pdns.service",
        "systemctl start pdns.service"
        ]
    }
}
