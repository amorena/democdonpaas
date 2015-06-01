#!/bin/bash

: ${SSH_USERNAME:=git}
: ${SSH_USERPASS:=git}

__create_rundir() {
	mkdir -p /var/run/sshd
}

__create_user() {
# Create a user to SSH into as.
useradd $SSH_USERNAME
echo -e "$SSH_USERPASS\n$SSH_USERPASS" | (passwd --stdin $SSH_USERNAME)
echo ssh user password: $SSH_USERPASS
}

__create_hostkeys() {
ssh-keygen -t rsa -f /etc/ssh/ssh_host_rsa_key -N '' 
}

__start_jenkins() {
service jenkins restart 
}

# Call all functions
__create_rundir
__create_hostkeys
__create_user
__start_jenkins

exec "$@"
