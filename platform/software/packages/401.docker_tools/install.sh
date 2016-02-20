install_docker_tool() {
	cp "$1" /usr/local/bin/ -f
	local docker_tools_file=/usr/local/bin/docker_tools.sh
	sed -i 's/DOCKER_BIN=docker/DOCKER_BIN="sudo docker"/g' "$docker_tools_file"
	chmod a+x "$docker_tools_file"
}

local archives="docker_tools.sh"
local install="install_docker_tool"
