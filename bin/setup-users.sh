#!/bin/bash
# Sets up users on a new server

create_user () {
	user=${1}
	sshdir="/home/${user}/.ssh"
	auth="authorized_keys"
	adduser --gecos "" --quiet --disabled-password ${user}
	usermod -a -G admin ${user}
}

setup_users () {
	getent group admin > /dev/null 2&>1 || groupadd admin
	while IFS= read -r line; do
		# skip comments
		( grep -q "^\s*#" <<< ${line} || grep -q "^$" <<< ${line} ) && continue
		# users file is formatted like this:
		# localname githubname
		read user_local user_github <<< ${line}
		# create user account if not found
		getent passwd ${user_local} > /dev/null 2&>1 || create_user ${user_local}
		sshdir="/home/${user_local}/.ssh"
		auth="${sshdir}/authorized_keys"
		# create necessary dir/file
		[[ -d "${sshdir}" ]] || ( mkdir -p "${sshdir}"; chmod 700 ${sshdir}; chown ${user_local}:${user_local} ${sshdir} )
		[[ -f "${auth}" ]] || ( touch ${auth}; chmod 600 ${auth}; chown ${user_local}:${user_local} ${auth} )
		# get keys from github
		curl -s "https://api.github.com/users/${user_github}/keys" | jshon -a -e key -u > ${auth}
	done < users
}

# edit sudoers
perms="%admin  ALL=(ALL:ALL) NOPASSWD: ALL"
sudoers="/etc/sudoers"
if [ -z "${1}" ]; then
	grep -q "${perms}" ${sudoers} || ( export EDITOR=$0 && sudo -E visudo )
	setup_users
# visudo calls this script with $1 as the path to the sudoers file
else
	echo "Users in 'admin' group can use sudo without using a password"
	(grep -v "^[%r#]" ${sudoers} | grep .; echo "${perms}") > ${1}
fi

