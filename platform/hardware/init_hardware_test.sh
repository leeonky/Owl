. $SHUNIT2_PATH/shunit2_mock
. "$(dirname "$0")/init_hardware.sh"

setUp() {
	mock_function grub2_mkconfig
	kernel_base_args="crashkernel=auto rd.lvm.lv=centos/root rd.lvm.lv=centos/swap rhgb quiet"

	stderrf="$SYS_TEMP_PATH/stderrf"
	rm -f $stderrf
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

test_shall_set_booton() {
	mock_function get_eth_device_name 'echo ethx'
	mock_function set_eth_boot_on 

	main

	mock_verify get_eth_device_name EXACTLY_CALLED 1
	mock_verify set_eth_boot_on ONLY_CALLED_WITH '/etc/sysconfig/network-scripts/' 'ifcfg-ethx'
}

test_change_ifcfg_booton_on() {
	cat > /tmp/ifcfg <<EOF
ONBOOT=no
EOF

	set_eth_boot_on /tmp/ ifcfg

	assertEquals 0 $?
	assertEquals "ONBOOT=yes" "$(cat /tmp/ifcfg)"
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
	mock_function set_eth_boot_on 

	main 2>"$stderrf"

	assertEquals 100 $?
	assertEquals "get_eth_device_name failed, configure abort!" "$(cat "$stderrf")"
	mock_verify set_eth_boot_on NEVER_CALLED
}

. $SHUNIT2_PATH/shunit2

