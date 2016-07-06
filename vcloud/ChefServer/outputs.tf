output "address" {
	value = "${vcd_vapp.chefserver.ip}"
}

output "url" {
	value = "https://${vcd_vapp.chefserver.name}/"
}

output "knife_rb" {
	value = "${template_file.knife.rendered}"
}