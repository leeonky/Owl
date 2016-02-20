start_docker() {
	echo 'ALL    ALL=(ALL)       NOPASSWD: /usr/bin/docker' > /etc/sudoers.d/docker

	mkdir -p /root/.docker/
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

	if cat /etc/default/docker 2>/dev/null | grep -q 'daocloud.io'; then
		echo "Already config daocloud.io."
	else
		echo "DOCKER_OPTS=\"\$DOCKER_OPTS --registry-mirror=http://bd5fd403.m.daocloud.io\"" | sudo tee -a /etc/default/docker
	fi

	systemctl enable docker.service
	systemctl start docker.service
}

local archives="docker-selinux-1.8.2-10.el7.centos.x86_64.rpm docker-1.8.2-10.el7.centos.x86_64.rpm"
local install="rpm -ivh"
#local pre_install=""
local post_install="start_docker"
