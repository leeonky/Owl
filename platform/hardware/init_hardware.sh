
grub2_mkconfig() {
	grub2-mkconfig "$@"
}

change_eth_name_machnism() {
	if cat "$1" | grep GRUB_CMDLINE_LINUX | grep -vq 'net.ifnames=0'; then
		sed 's/\(^GRUB_CMDLINE_LINUX.*\)"$/\1 net.ifnames=0"/g' -i $1
	fi
	if cat "$1" | grep GRUB_CMDLINE_LINUX | grep -vq 'biosdevname=0'; then
		sed 's/\(^GRUB_CMDLINE_LINUX.*\)"$/\1 biosdevname=0"/g' -i $1
	fi
	grub2_mkconfig -o /boot/grub2/grub.cfg
}

check_last_return() {
	return $?
}

log_error() {
	local res=$?
	echo "$1" >&2
	return $res
}

get_eth_device_name() {
	nmcli con show | grep -v TYPE | grep -v generic | grep -v bridge | awk '{print $1}'
}

set_eth_boot_on() {
	if cat "$1/$2" | grep -q -e "^ONBOOT="; then
		sed 's/\(^ONBOOT\)=.*/\1=yes/g' -i "$1/$2"
	else
		echo "ONBOOT=yes" >> "$1/$2"
	fi
}

main() {
	#change_eth_name_machnism /etc/default/grub
	local eth_device_name
	eth_device_name=$(get_eth_device_name)
	( check_last_return || log_error "get_eth_device_name failed, configure abort!" ) && \
	( set_eth_boot_on /etc/sysconfig/network-scripts/ ifcfg-$eth_device_name || log_error "set_eth_boot_on failed, configure abort!" )
}

