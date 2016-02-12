disable_root_remote_login() {
	if cat "$1" | grep -q "^PermitRootLogin"; then
		sed 's/^PermitRootLogin.*/PermitRootLogin no/g' -i $1
	else
		echo 'PermitRootLogin no' >> $1
	fi
}
