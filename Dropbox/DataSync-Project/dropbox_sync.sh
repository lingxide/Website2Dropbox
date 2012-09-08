#!/bin/bash
initd(){
	if   [[   $V1   ==   "install"   ]]
	then
		if [ "`uname -m`" == "x86_64" ]; then
			cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86_64" | tar xzf -
		else if [ "`uname -m`" == "i686" ]; then
			cd ~ && wget -O - "https://www.dropbox.com/download?plat=lnx.x86" | tar xzf -
			else
				echo 'No version available!'
				exit
			fi
		fi
		mkdir ~/Dropbox/mysql
		echo 'Now, get ready to copy the url to your browser and complete the installation.'
		echo 'This script will exit, you can run it again to sync without "install".'
		echo 'Press enter to continue...'
		read null
		~/.dropbox-dist/dropboxd &
		exit
	fi

	###Please modify the following settings###
	#Source Path, the path that you would like to backup
	SOURCE="/path/to/the/source/folder";

	#Target Path，Please test "cd $HOME/Dropbox" before making any changes (if it points to the correct path, you don't need to change anything)
	TARGET="$HOME/Dropbox";
	#mysqldump module，Please use "updatedb && locate mysqldump" if you are uncertain about the mysqldump path
	mysqldump="/usr/bin/mysqldump";
	#Mysql Database credential
	USERNAME="dbuser";
	PASSWORD='dbpassword';
	#Databases that you would like to backup, separate with space for multiple databases
	DATABASE="db1 db2 db3";
	#Initiate current path
	cd $TARGET
	###Please modify the above settings###
	DATE=`date --rfc-3339=date`;

	killall dropbox
	echo "Dropbox KILLED."
}

dropboxd(){
	~/.dropbox-dist/dropboxd &
	echo "Dropbox RESTARTED."
}

filed(){
	echo "File Copy Process START"
	cp -uaf $SOURCE/* $TARGET
	echo "Files Copy Process Completed."
}

mysqld(){
	cd $TARGET/mysql
	$mysqldump -u $USERNAME --password=$PASSWORD --databases $DATABASE > mysql-$DATE.sql && gzip -f mysql-$DATE.sql
	echo "Mysql Database(s) BACKUPED."
}

paused(){
	echo "Pause 10 mins for data syncing to Dropbox..."
	#Please wait 10 mins, if it's the first time, please change it to 60m
	sleep 10m
	echo "KILLING Dropbox..."
	killall dropbox
	echo "Dropbox Process KILLED."
	#Kill Dropbox process to avoid CPU high occupancy
}
main(){
	#Comment out the process you don't need with "#"
	initd
	dropboxd
	filed
	mysqld
	paused
	echo "Dropbox SYNC FINISHED."
}
#Pass in parameters
V1=$1;
main
