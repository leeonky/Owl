. "$(dirname "$0")/../hardware/conf"
setUp(){
	eth_device=$(nmcli con show | grep -v TYPE | grep -v generic | grep -v bridge | awk '{print $1}')
	[ "$eth_device" != "" ]
	assertTrue "fail to get eth device name." $?
}


ignor_test_eth_name_shall_eth0() {
	ifconfig eth0 2>&1 1>/dev/null
	assertEquals 0 $?
}

test_ethx_shall_up_after_boot() {
	ifconfig "$eth_device" | grep -q netmask

	assertTrue "eth may be down" $?
}

test_ip_config() {
	ip_infos="$(ifconfig "$eth_device" | grep netmask)"

	assertEquals "IP" "$ip_addr" "$(echo "$ip_infos" | awk '{print $2}')"
	assertEquals "NETMASK" "$netmask" "$(echo "$ip_infos" | awk '{print $4}')"
	assertEquals "GATEWAY" "$gateway" "$(route -n | grep '^0.0.0.0' | awk '{print $2}')"
	assertEquals "DNS" "nameserver" "$(cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $1}')"
	assertEquals "DNS" "$gateway" "$(cat /etc/resolv.conf | grep nameserver | head -n 1 | awk '{print $2}')"
}

. $SHUNIT2_PATH/shunit2

