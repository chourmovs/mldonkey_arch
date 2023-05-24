#!/bin/sh

#########################################
##           CREATE FOLDERS            ##
#########################################
# Create files and directories folders if they don't exist

mkdir -p \
 	/mnt/mldonkey_completed/files \
	/mnt/mldonkey_completed/directories


#########################################
##          SET PERMISSIONS            ##
#########################################
# create a "docker" user if he don't exist

if id -u docker >/dev/null 2>&1; then
    echo 'user exists'
else
    echo 'user missing'
    useradd -U -d /var/lib/mldonkey docker
fi


#########################################
##        ENVIRONMENTAL CONFIG         ##
#########################################

#Apply the given parameters on first boot (PGID, PUID, TZ)
if [ ! -f "/var/lib/mldonkey/initialbootpassed" ]
	then
       	echo "-------> Initial boot"
	
	# create a "docker" user
	useradd -U -d /var/lib/mldonkey docker
	
	# Create files and directories folders
	 mkdir -p \
	/mnt/mldonkey_completed/files \
	/mnt/mldonkey_completed/directories
	
	#Delete any *.ini.tmp files which may prevent mldonkey to start
	cd /var/lib/mldonkey
	rm -f *.ini.tmp
	 
	 
	if [ -n "${PGID}" ]
		then
		OLDGID=$(id -g docker)
		groupmod -g $PGID docker
		find / -group $OLDGID -exec chgrp -h docker {} \;
	fi

	if [ -n "${PUID}" ]
		then
		OLDUID=$(id -u docker)
		usermod -u $PUID docker
		find / -user $OLDUID -exec chown -h docker {} \;
	fi

	if [ -n "${TZ}" ]; then echo $TZ > /etc/timezone; fi

	touch /var/lib/mldonkey/initialbootpassed

	#Setup mldlonkey (need to be started once to create the proper files before copying the defaults)
	mldonkey &
	echo "Waiting for mldonkey to start..."
	sleep 5
	/usr/lib/mldonkey/mldonkey_command -p "" "kill"

	# copy the config files
	cp -r /defaults/. /var/lib/mldonkey/

	# Set the permissions
	chown -R docker:docker \
		/var/lib/mldonkey \
		/mnt/mldonkey_completed \
		/mnt/mldonkey_tmp
	else
	echo "-------> Standard boot"
	exec mldonkey
	
fi
