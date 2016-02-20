DOCKER_BIN=docker
retain_images() {
	local image_list="$($DOCKER_BIN images)"
	local target_images="$(echo "$image_list" | grep "^$1 " | awk '{print $1":"$2}' | grep -v $1:$2)"
	if [ "" != "$target_images" ]; then
		local all_containers="$($DOCKER_BIN ps)"
		local target_containers="$(echo "$all_containers" | grep " $1:" | grep -v " $1:$2 "|  awk '{print $1}')"
		if [ "" != "$target_containers" ]; then
			echo "$DOCKER_BIN stop $target_containers"
			$DOCKER_BIN stop $target_containers
		fi
		all_containers="$($DOCKER_BIN ps -a)"
		target_containers="$(echo "$all_containers" | grep " $1:" | grep -v " $1:$2 "|  awk '{print $1}')"
		if [ "" != "$target_containers" ]; then
			echo "$DOCKER_BIN rm $target_containers"
			$DOCKER_BIN rm $target_containers
		fi
		echo "$DOCKER_BIN rmi $target_images"
		$DOCKER_BIN rmi $target_images
	fi
}

docker_tool_option=$1
shift 1
case $docker_tool_option in
retain)
	retain_images "$@"
;;
esac
