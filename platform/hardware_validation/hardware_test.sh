. "$(dirname "$0")/../hardware/conf"

ignor_test_eth_name_shall_eth0() {
	ifconfig eth0 2>&1 1>/dev/null
	assertEquals 0 $?
}

test_ethx_shall_up_after_boot() {
	eth_device=$(nmcli con show | grep -v TYPE | grep -v generic | grep -v bridge | awk '{print $1}')
	[ "$eth_device" != "" ]
	assertTrue "fail to get eth device name." $?

	ifconfig "$eth_device" | grep -q netmask

	assertTrue "eth may be down" $?
}

. $SHUNIT2_PATH/shunit2

