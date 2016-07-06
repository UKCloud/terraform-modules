# See https://docs.getchef.com/config_rb_knife.html for more information on knife configuration options

current_dir = File.dirname(__FILE__)
log_level                :info
log_location             STDOUT
node_name                "${node_name}"
client_key               "#{current_dir}/${node_name}.pem"
validation_client_name   "${validation_client_name}"
validation_key           "#{current_dir}/${validation_client_name}.pem"
chef_server_url          "${chef_server_url}"
cookbook_path            ["#{current_dir}/../cookbooks"]
