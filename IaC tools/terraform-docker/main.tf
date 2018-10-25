#Terraform Docker Provider
provider "docker" {
	host = "tcp://127.0.0.1:2376/"
	# host = "tcp://your_docker_host_ip:2376"
  
	# Optional: Include and auth a docker registry to serve images locally and avoid 
	# network download everytime.
	registry_auth {
		address = "registry.hub.docker.com"
		# Use from variables.tf
		username = "registry_user"
		password = "registry_pass"
	}
	
	# For security reasons, you can pass the config file.
	# config_file = "~/.docker/config.json"
		
	# Optional: Specify docker ceritifcate directory location or file path as:
	test_cert_file = "${file(pathexpand("~/.docker/cert.pem"))}"
	
}


# Docker image resource
resource "docker_image" "ubuntu_test1" {

	# Docker image name, including any tags or SHA256 repo digests.
	name = "ubuntu:latest"
  
	# Optional : If docker registry is present for pulling the image and defined with provider.
	# Use the below, you can also define a pull_triggers to make images latest.
	# pull_triggers = ["${data.docker_registry_image.ubuntu.sha256_digest}"]

	# Optional: keep_locally
	# On terraform destroy, if we want to keep the image locally, set this flag to True
	# keep_locally = true
}

# This should be in a separate file, along with other variables.
data "docker_registry_img" "ubuntu" {
	name  = "Unbuntu:alpine"
}

# Docker container resource
resource "docker_container" "test_server" {
	# Name of the container.
	name = "test_server"
	
	# Image ID for the container, taken from the resource "docker_image"
        image = "${docker_image.ubuntu_test1.latest}"
  
	# Lets open up a port for the docker container.
	# publish_all_ports = true
	ports {
		internal = 80
		external = 80
	}
	
	# There are other options to define and can used as follows:
	# domainname = "test_framework.int"
    # count = "${var.test_servers_cnt}"
    # must_run = true
    # restart = "always"
    # privileged = true
    # env = ["env=test_user", "role=test_user"]
    # command = ["/usr/sbin/sshd"]
	network_mode = "bridge"
    networks = [ "${docker_network.private_network.name}" ]

}

# Terraform Docker network
resource "docker_network" "private_network" {
	name = "test_network"
	
	# --driver=bridge
	# --subnet=172.xx.0.x/16
	# --ip-range=172.xx.5.x/24
	# --gateway=172.xx.5.254
}

# Lets create a volume for the container.
resource "docker_volume" "shared_volume" {
	name = "shared_volume"
	
	container_path = "/usr/share/test_dir"
	host_path = "/home/tutorial/www"
	read_only = true
}
