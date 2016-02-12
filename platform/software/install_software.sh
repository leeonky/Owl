show_status() {
	echo ">>>$1"
}

disable_root_remote_login() {
	if cat "$1" | grep -q "^PermitRootLogin"; then
		sed 's/^PermitRootLogin.*/PermitRootLogin no/g' -i $1
	else
		echo 'PermitRootLogin no' >> $1
	fi
}

security_config(){
	show_status 'Security config'
	disable_root_remote_login /etc/ssh/sshd_config
}

install_packages() {
	local conf
	for conf in $(ls "$1/archives.conf/")
	do
		show_status "Installing $conf"
		unset pre_install
		unset post_install
		unset install
		unset archives 
		. "$1/archives.conf/$conf"
		${pre_install:-}
		local arch
		for arch in ${archives:-}
		do
			${install:-} "$1/archives/$arch"
		done
		${post_install:-}
	done
	return 0
}

software_install() {
	install_packages "$(dirname "$0")/packages"
}

main() {
	security_config && \
	software_install
}

