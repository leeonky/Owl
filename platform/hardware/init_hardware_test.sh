. $SHUNIT2_PATH/shunit2_mock
. "$(dirname "$0")/init_hardware.sh"

setUp() {
	mock_function grub2_mkconfig
	kernel_base_args="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
}

test_shall_configure_eth_name() {
	mock_function change_eth_name_machnism

	main

	mock_verify change_eth_name_machnism EXACTLY_CALLED 1
}

test_change_eth_name_machnism_via_grub_config() {
	cat > /tmp/test_grub <<EOF
GRUB_CMDLINE_LINUX="$kernel_base_args"
EOF
	change_eth_name_machnism /tmp/test_grub

	assertEquals "GRUB_CMDLINE_LINUX=\"$kernel_base_args net.ifnames=0 biosdevname=0\"" "$(cat /tmp/test_grub)"
	mock_verify grub2_mkconfig ONLY_CALLED_WITH -o /boot/grub2/grub.cfg
}

test_change_eth_name_machnism_when_grub_args_already_configed() {
	cat > /tmp/test_grub <<EOF
GRUB_CMDLINE_LINUX="$kernel_base_args net.ifnames=0 biosdevname=0"
EOF
	change_eth_name_machnism /tmp/test_grub

	assertEquals "GRUB_CMDLINE_LINUX=\"$kernel_base_args net.ifnames=0 biosdevname=0\"" "$(cat /tmp/test_grub)"
}

test_change_eth_name_machnism_when_only_set_net_ifnames() {
	cat > /tmp/test_grub <<EOF
GRUB_CMDLINE_LINUX="$kernel_base_args net.ifnames=0"
EOF
	change_eth_name_machnism /tmp/test_grub

	assertEquals "GRUB_CMDLINE_LINUX=\"$kernel_base_args net.ifnames=0 biosdevname=0\"" "$(cat /tmp/test_grub)"
}

test_change_eth_name_machnism_when_only_set_biosdevname() {
	cat > /tmp/test_grub <<EOF
GRUB_CMDLINE_LINUX="$kernel_base_args biosdevname=0"
EOF
	change_eth_name_machnism /tmp/test_grub

	assertEquals "GRUB_CMDLINE_LINUX=\"$kernel_base_args biosdevname=0 net.ifnames=0\"" "$(cat /tmp/test_grub)"
	
}

. $SHUNIT2_PATH/shunit2

