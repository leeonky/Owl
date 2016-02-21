install_eclipse() {
	local eclipse_bin=/usr/local/bin/eclipse
	cat > "$eclipse_bin" <<EOF
APP_VERSION=2.1.1
docker_tools.sh retain daocloud.io/leeonky/eclipse-jdt-cdt \$APP_VERSION
mkdir -p ~/eclipse_workspace
sudo docker run --rm --privileged=true -e DISPLAY=\$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v ~:/home/devuser/volumn:rw daocloud.io/leeonky/eclipse-jdt-cdt:\$APP_VERSION eclipse -data /home/devuser/volumn/eclipse_workspace/ 2>&1 1>/dev/null
EOF
	chmod a+x "$eclipse_bin"
}

local install="install_eclipse"
