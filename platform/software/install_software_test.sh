. $SHUNIT2_PATH/shunit2_mock
. "$(dirname "$0")/install_software.sh"

mock_stubs() {
	mock_function disable_root_remote_login
	mock_function install_packages
}

test_security_config() {
	mock_stubs

	main

	mock_verify disable_root_remote_login ONLY_CALLED_WITH /etc/ssh/sshd_config
}

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
	assertEquals 'PermitRootLogin no' "$(cat /tmp/sshconf | grep ^PermitRootLogin )"
}

test_disable_root_remote_login_again(){
	cat > /tmp/sshconf<<EOF
#dummy
PermitRootLogin no
EOF
	disable_root_remote_login /tmp/sshconf

	assertEquals '1' "$(cat /tmp/sshconf | grep ^PermitRootLogin | wc -l)"
	assertEquals 'PermitRootLogin no' "$(cat /tmp/sshconf | grep ^PermitRootLogin )"
}

test_shall_install_software() {
	mock_stubs

	main

	mock_verify install_packages ONLY_CALLED_WITH "$(dirname "$0")/packages"
}

test_install_rpms() {
	unset the_path
	mock_function install_command 'the_path=$(pwd)'
	mock_clear_called_list
	local test_arch="$SYS_TEMP_PATH/testpackages"
	rm -rf "$test_arch"
	mkdir -p "$test_arch"
	mkdir -p "$test_arch/01.Test1"
	cat > "$test_arch/01.Test1/install.sh"<<EOF
local archives="a.rpm b.rpm"
local install="install_command"
local pre_install="install_command pre"
local post_install="install_command post"
EOF

	install_packages "$test_arch"

	mock_verify install_command COOP_CALLED_WITH_ARGS pre
	mock_verify install_command COOP_CALLED_WITH_ARGS "a.rpm" "b.rpm"
	mock_verify install_command COOP_CALLED_WITH_ARGS post
	mock_verify_all_called_end
	assertEquals "$test_arch/01.Test1" "$the_path" 
}

itest_install_without_pre_post() {
	mock_function install_command
	mock_clear_called_list
	local test_arch="$SYS_TEMP_PATH/testpackages"
	rm -rf "$test_arch"
	mkdir -p "$test_arch"
	mkdir -p "$test_arch/01.Test1"
	cat > "$test_arch/01.Test1/install.sh"<<EOF
local archives="a.rpm b.rpm"
local install="install_command"
EOF

	install_packages "$test_arch"

	mock_verify install_command COOP_CALLED_WITH_ARGS "$test_arch/01.Test1/a.rpm"
	mock_verify install_command COOP_CALLED_WITH_ARGS "$test_arch/01.Test1/b.rpm"
	mock_verify_all_called_end
}

itest_multi_install_by_ordey() {
	mock_function install_command1
	mock_function install_command2
	mock_clear_called_list
	local test_arch="$SYS_TEMP_PATH/testpackages"
	rm -rf "$test_arch"
	mkdir -p "$test_arch"
	mkdir -p "$test_arch/02.Test1"
	cat > "$test_arch/02.Test1/install.sh"<<EOF
local archives="b.rpm"
local install="install_command2"
local pre_install="install_command2 pre"
local post_install="install_command2 post"
EOF
	mkdir -p "$test_arch/01.Test1"
	cat > "$test_arch/01.Test1/install.sh"<<EOF
local archives="a.rpm"
local install="install_command1"
local pre_install="install_command1 pre"
local post_install="install_command1 post"
EOF

	install_packages "$test_arch"

	mock_verify install_command1 COOP_CALLED_WITH_ARGS pre
	mock_verify install_command1 COOP_CALLED_WITH_ARGS "$test_arch/01.Test1/a.rpm"
	mock_verify install_command1 COOP_CALLED_WITH_ARGS post
	mock_verify install_command2 COOP_CALLED_WITH_ARGS pre
	mock_verify install_command2 COOP_CALLED_WITH_ARGS "$test_arch/02.Test1/b.rpm"
	mock_verify install_command2 COOP_CALLED_WITH_ARGS post
	mock_verify_all_called_end
}

. $SHUNIT2_PATH/shunit2
