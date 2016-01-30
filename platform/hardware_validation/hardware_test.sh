ignor_test_eth_name_shall_eth0() {
	ifconfig eth0 2>&1 1>/dev/null
	assertEquals 0 $?
}

. $SHUNIT2_PATH/shunit2

