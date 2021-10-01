
get_remote_ssh_cmd(){
  local u="$1"
  local h="$2"
  local s="$3"
  local e="$4"
  local rem_cmd="$5"
  local post_cmd='exit $?'
cmd="2>/tmp/.time time >/tmp/.o 2>/tmp/.e command ssh -t -oUser=$u '$h' command env $e command $s +e +x -l << EOF
eval $rem_cmd;
exit;
EOF
echo \$?"
#>/tmp/.ec 
echo -e "$cmd"

}



















fd_setup() {
	exec 3>&1 4>&2 5>&2
}
loggerForStdout() {
	# FD 3 is the original stdout
	local x
	while IFS= read -r x; do printf "STDOUT\t%s\n" "$x"; done >&4
}
loggerForExitCode() {
	local x
	local cmd="$1"
	while IFS= read -r x; do printf "EXIT_CODE\t'$cmd' => \t%d\n" "$x"; done >&5
}
loggerForStderr() {
	# FD 4 is the original stderr
	local x
	while IFS= read -r x; do printf "STDERR\t%s\n" "$x"; done >&2
}

wrap_Exec() {
	local cmd="$1"
	local stdout_file="$2"
	local stderr_file="$3"
	local ec_file="$4"
	local cp=$$
	( (
		stdbuf -oL -eL env $(command -v bash) --norc --noprofile +x +e -c "$cmd"
		{ echo -e "$?" | tee $ec_file >/dev/null; }
	) | tee $stdout_file | loggerForStdout) 2>&1 | tee $stderr_file | loggerForStderr
	cat $ec_file | loggerForExitCode "$cmd" >/dev/null
	return $(cat $ec_file)
}

fd_setup

stdout_file=$(mktemp)
stderr_file=$(mktemp)
ec_file=$(mktemp)
cmd="ls /a && ls /b; ls /c; ls /22;find /|head -n10;ls /11;"
cmd="ls /a"
cmd="ls /"
cmd="ls /;ls /a && ls /b; ls /c; ls /22;find /|head -n10;ls /11;"
wrap_Exec \
	"$cmd" "$stdout_file" "$stderr_file" "$ec_file"
ec=$?
err="$(cat $stderr_file)"
out="$(cat $stdout_file)"

ansi --yellow "$cmd"
ansi --red "$err"
ansi --green "$out"
ansi --cyan "$ec"
exit $ec
