start_docker() {
	systemctl enable docker.service
	systemctl start docker.service
}

local archives="docker-selinux-1.8.2-10.el7.centos.x86_64.rpm docker-1.8.2-10.el7.centos.x86_64.rpm"
local install="rpm -ivh"
#local pre_install=""
local post_install="start_docker"
