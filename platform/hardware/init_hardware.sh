
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

main() {
	#change_eth_name_machnism /etc/default/grub
	return
}

