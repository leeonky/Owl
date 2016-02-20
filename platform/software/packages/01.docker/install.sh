start_docker() {
	if cat /etc/default/docker | grep -q 'daocloud.io'; then
		echo "Already config daocloud.io."
	else
		echo "DOCKER_OPTS=\"\$DOCKER_OPTS --registry-mirror=http://bd5fd403.m.daocloud.io\"" | sudo tee -a /etc/default/docker
	fi

	echo 'ALL    ALL=(ALL)       NOPASSWD: /usr/bin/docker' > /etc/sudoers.d/docker

	cat > /root/.docker/config.json <<EOF
{
        "auths": {
                "daocloud.io": {
                        "auth": "bGVlb25reTp0Mjd5YnJxZHRm",
                        "email": "leeonky@gmail.com"
                }
        }
}
EOF

	systemctl enable docker.service
	systemctl start docker.service
}

local archives="docker-selinux-1.8.2-10.el7.centos.x86_64.rpm docker-1.8.2-10.el7.centos.x86_64.rpm"
local install="rpm -ivh"
#local pre_install=""
local post_install="start_docker"
