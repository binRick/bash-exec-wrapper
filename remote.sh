get_remote_ssh_cmd() {
	local u="$1"
	local h="$2"
	local s="$3"
	local e="$4"
	local rem_cmd="$5"
	local post_cmd='exit $?'

	NEW_PROFILE=dfb_tbl
	PROFILE=Goonies
	if [[ "$NEW_PROFILE" != "" ]]; then
		if [[ "$PROFILE" != "" ]]; then
			echo >&2 Saving Profile $PROFILE
			export SAVED_PROFILE="$PROFILE"

			restore_profile() {
				echo >&2 -e "\n\nRestoring Profile $(ansi --green --bg-black --underline $SAVED_PROFILE)"
				#      echo -e "\033]50;SetProfile=${SAVED_PROFILE}\a"

			}
		fi
	fi

	#trap restore_profile SIGINT
	#trap restore_profile RETURN

	cmd="echo -e \"\\\033]50;SetProfile=${NEW_PROFILE}\\\a\"; clear"
	cmd="$cmd && 2>/tmp/.time time >/tmp/.o 2>/tmp/.e command ssh -t -oUser=$u '$h' command env $e command $s +e +x -l << EOF
eval $rem_cmd;
exit;
EOF
>/tmp/.ec echo \$?"
	cmd="$cmd; echo -e \"\\\033]50;SetProfile=${SAVED_PROFILE}\\\a\""
	echo -e "$cmd"

}

