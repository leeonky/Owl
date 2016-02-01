. "$(dirname "$0")/conf"

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

update_ifcfg_by_name() {
	local name=$1
	local value=$2
	local ifcfg_file="$3"
	if cat "$ifcfg_file" | grep -q -e "^$name="; then
		sed "s/\(^$name\)=.*/\1=$value/g" -i "$ifcfg_file"
	else
		echo "$name=$value" >> "$ifcfg_file"
	fi
}

remove_ifcfg_by_name() {
	sed "/^$1=.*/d" -i "$2"
}

update_eth_conf() {
	update_ifcfg_by_name ONBOOT yes "$1"
	update_ifcfg_by_name BOOTPROTO none "$1"
	update_ifcfg_by_name IPADDR "$2" "$1"
	update_ifcfg_by_name NETMASK "$3" "$1"
	update_ifcfg_by_name GATEWAY "$4" "$1"
	remove_ifcfg_by_name PREFIX "$1"
}

update_dns() {
	echo "nameserver $2" > "$1"
}

main() {
	#change_eth_name_machnism /etc/default/grub
	local eth_device_name
	eth_device_name=$(get_eth_device_name)
	( check_last_return || log_error "get_eth_device_name failed, configure abort!" ) && \
	update_eth_conf "/etc/sysconfig/network-scripts/ifcfg-$eth_device_name" $ip_addr $netmask $gateway && \
	update_dns /etc/resolv.conf $gateway
}

