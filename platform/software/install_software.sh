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
	local entry
	for entry in $(ls "$1")
	do
		show_status "Installing $entry"
		unset pre_install
		unset post_install
		unset install
		unset archives 
		cd "$1/$entry"
		. ./install.sh
		${pre_install:-}
		${install:-} ${archives:-}
		${post_install:-}
		cd - >/dev/null
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

