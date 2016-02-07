. $SHUNIT2_PATH/shunit2_mock
. "$(dirname "$0")/install_software.sh"

test_first_disable_root_remote_login(){
	cat > /tmp/sshconf<<EOF
#dummy
EOF
	disable_root_remote_login /tmp/sshconf

	assertEquals 'PermitRootLogin no' "$(cat /tmp/sshconf | grep ^PermitRootLogin )"
}

test_change_disable_root_remote_login(){
	cat > /tmp/sshconf<<EOF
#dummy
PermitRootLogin yes
EOF
	disable_root_remote_login /tmp/sshconf

	assertEquals '1' "$(cat /tmp/sshconf | grep ^PermitRootLogin | wc -l)"
}


. $SHUNIT2_PATH/shunit2
