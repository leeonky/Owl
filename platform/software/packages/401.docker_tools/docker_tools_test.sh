. $SHUNIT2_PATH/shunit2_mock

test_no_image_rm_for_upgrade(){
	mock_function docker 'if [ $1 == images ]; then
cat <<EOF
REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
EOF
fi'

	. "$(dirname "$0")/docker_tools.sh" retain daocloud.io/leeonky/centos-base new

	mock_verify docker NEVER_CALLED_WITH rmi __ANY_LAST__
}

test_rm_one_image_with_no_container_for_upgrade(){
	mock_function docker 'if [ $1 == images ]; then
cat <<EOF
REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
daocloud.io/leeonky/centos-base   latest              b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-basexx latest              b639c35ff265        13 hours ago        723.3 MB
EOF
fi'

	. "$(dirname "$0")/docker_tools.sh" retain daocloud.io/leeonky/centos-base new

	mock_verify docker HAS_CALLED_WITH rmi daocloud.io/leeonky/centos-base:latest
}

test_rm_multi_images_with_no_container_for_upgrade(){
	mock_function docker 'if [ $1 == images ]; then
cat <<EOF
REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
daocloud.io/leeonky/centos-base   new                 b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-base   latest              b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-base   1.1.1               b639c35ff265        13 hours ago        723.3 MB
EOF
fi
if [ $1 == ps ]; then
return
fi
'

	. "$(dirname "$0")/docker_tools.sh" retain daocloud.io/leeonky/centos-base new

	mock_verify docker HAS_CALLED_WITH rmi daocloud.io/leeonky/centos-base:latest daocloud.io/leeonky/centos-base:1.1.1
}

test_rm_stopped_container_before_rm_images() {
	mock_function docker 'if [ $1 == images ]; then
cat <<EOF
REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
daocloud.io/leeonky/centos-base   new                 b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-base   latest              b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-base   1.1.1               b639c35ff265        13 hours ago        723.3 MB
EOF
fi
if [ $1 == ps ]; then
	if [ $# == 2 ]; then
cat <<EOF
CONTAINER ID        IMAGE                                            COMMAND             CREATED             STATUS                      PORTS               NAMES
001                 daocloud.io/leeonky/centos-base:latest           "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
002                 daocloud.io/leeonky/centos-base:latest           "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
003                 daocloud.io/leeonky/centos-base:new              "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
EOF
	fi
fi
'

	. "$(dirname "$0")/docker_tools.sh" retain daocloud.io/leeonky/centos-base new

	mock_verify docker HAS_CALLED_WITH rm 001 002
	mock_verify docker HAS_CALLED_WITH rmi daocloud.io/leeonky/centos-base:latest daocloud.io/leeonky/centos-base:1.1.1
}

test_stop_running_container_before_rm_images() {
	mock_function docker 'if [ $1 == images ]; then
cat <<EOF
REPOSITORY                        TAG                 IMAGE ID            CREATED             VIRTUAL SIZE
daocloud.io/leeonky/centos-base   new                 b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-base   latest              b639c35ff265        13 hours ago        723.3 MB
daocloud.io/leeonky/centos-base   1.1.1               b639c35ff265        13 hours ago        723.3 MB
EOF
fi
if [ $1 == ps ]; then
	if [ $# == 2 ]; then
cat <<EOF
CONTAINER ID        IMAGE                                            COMMAND             CREATED             STATUS                      PORTS               NAMES
001                 daocloud.io/leeonky/centos-base:latest           "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
002                 daocloud.io/leeonky/centos-base:latest           "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
003                 daocloud.io/leeonky/centos-base:new              "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
EOF
	else
cat <<EOF
CONTAINER ID        IMAGE                                            COMMAND             CREATED             STATUS                      PORTS               NAMES
001                 daocloud.io/leeonky/centos-base:latest           "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
004                 daocloud.io/leeonky/centos-base:new              "echo hello"        35 seconds ago      Exited (0) 34 seconds ago                       gloomy_cori
EOF
	fi
fi
'

	. "$(dirname "$0")/docker_tools.sh" retain daocloud.io/leeonky/centos-base new

	mock_verify docker HAS_CALLED_WITH stop 001
	mock_verify docker HAS_CALLED_WITH rm 001 002
	mock_verify docker HAS_CALLED_WITH rmi daocloud.io/leeonky/centos-base:latest daocloud.io/leeonky/centos-base:1.1.1
	
}

. $SHUNIT2_PATH/shunit2
