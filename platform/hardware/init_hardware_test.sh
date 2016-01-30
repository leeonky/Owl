. $SHUNIT2_PATH/shunit2_mock
. "$(dirname "$0")/init_hardware.sh"

setUp() {
	clear_global_vars
	mock_function grub2_mkconfig
	kernel_base_args="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"
}

ignor_test_shall_configure_eth_name() {
	mock_function change_eth_name_machnism

	main

	mock_verify change_eth_name_machnism ONLY_CALLED_WITH /etc/default/grub
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

test_get_eth_device_name() {
	mock_function nmcli 'echo "NAME         UUID                                  TYPE            DEVICE     
virbr0-nic   faf0a387-1de1-4130-817b-cc9219d83456  generic         virbr0-nic 
virbr0       dfe08cbe-7bad-418c-9f72-ce2a9323fcf8  bridge          virbr0     
eno16777736  b2de10c7-6db3-4d60-be5b-5ce803425589  802-3-ethernet  --"'

	assertEquals eno16777736 "$(get_eth_device_name)"
	mock_verify nmcli ONLY_CALLED_WITH con show
}

test_shall_return_error_when_get_eth_device_name_error() {
	mock_function get_eth_device_name 'return 100'
	mock_function update_eth_conf

	main 2>"$stderrf"

	assertEquals 100 $?
	assertEquals "get_eth_device_name failed, configure abort!" "$(cat "$stderrf")"
	mock_verify update_eth_conf NEVER_CALLED
}

test_shall_update_eth_conf() {
	mock_function get_eth_device_name 'echo ethx'
	mock_function update_eth_conf

	main

	mock_verify get_eth_device_name EXACTLY_CALLED 1
	mock_verify update_eth_conf ONLY_CALLED_WITH '/etc/sysconfig/network-scripts/ifcfg-ethx' $ip_addr $netmask $gateway
}

test_change_ifcfg_booton_on() {
	cat > /tmp/ifcfg <<EOF
ONBOOT=no
EOF

	update_eth_conf /tmp/ifcfg

	assertEquals 0 $?
	assertEquals "ONBOOT=yes" "$(cat /tmp/ifcfg | grep ^ONBOOT)"
}

test_change_ifcfg_when_no_ONBOOT_item() {
	cat > /tmp/ifcfg <<EOF
XXONBOOT=no
EOF

	update_eth_conf /tmp/ifcfg

	assertEquals 0 $?
	assertEquals "ONBOOT=yes" "$(cat /tmp/ifcfg | grep ^ONBOOT)"
}

test_set_ipaddr_shall_disable_dhcp() {
	cat > /tmp/ifcfg <<EOF
BOOTPROTO=dhcp
EOF
	update_eth_conf /tmp/ifcfg

	assertEquals 'BOOTPROTO=none' "$(cat /tmp/ifcfg | grep ^BOOTPROTO)"
}

test_set_ipaddr_shall_set_ip() {
	cat > /tmp/ifcfg <<EOF
IPADDR=1.2.3.4
EOF
	update_eth_conf /tmp/ifcfg 192.168.1.111

	assertEquals 'IPADDR=192.168.1.111' "$(cat /tmp/ifcfg | grep ^IPADDR)"
}

test_set_ipaddr_shall_set_netmask() {
	cat > /tmp/ifcfg <<EOF
NETMASK=255.0.0.0
EOF
	update_eth_conf /tmp/ifcfg 192.168.1.111 255.255.255.0

	assertEquals 'NETMASK=255.255.255.0' "$(cat /tmp/ifcfg | grep ^NETMASK)"
}

test_set_ipaddr_shall_remove_PREFIX() {
	cat > /tmp/ifcfg <<EOF
PREFIX=8
EOF
	update_eth_conf /tmp/ifcfg 192.168.1.111 255.255.255.0

	assertEquals '' "$(cat /tmp/ifcfg | grep ^PREFIX)"
}

test_set_ipaddr_shall_set_gateway() {
	cat > /tmp/ifcfg <<EOF
GATEWAY=3.3.3.3
EOF
	update_eth_conf /tmp/ifcfg 192.168.1.111 255.255.255.0 192.168.1.1

	assertEquals 'GATEWAY=192.168.1.1' "$(cat /tmp/ifcfg | grep ^GATEWAY)"
}

. $SHUNIT2_PATH/shunit2

