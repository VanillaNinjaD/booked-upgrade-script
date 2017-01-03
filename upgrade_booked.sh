#!/bin/bash

#-----------------------
# DEFINE VARIABLES HERE
#-----------------------
WEBSERVICENAME="apache2"
WEBSERVERUSER="www-data"
WEBSERVERDIRECTORY="/var/www/"
BOOKEDDIRECTORY="booked"
MYSQLDUMPPATH="/usr/bin/mysqldump"
DBNAME="bookedscheduler"
DBUSER="**USERNAME**"
DBPASS="**PASSWORD**"

#----------------
# PERFORM CHECKS
#----------------
if [[ $EUID -ne 0 ]]; then
   echo "THIS SCRIPT MUST BE RUN AS ROOT!!!" 1>&2
   exit 1
fi
if [ -a booked-latest.zip ]
  then
    rm booked-latest.zip
fi

#--------------
# START SCRIPT
#--------------
wget -O booked-latest.zip -c https://sourceforge.net/projects/phpscheduleit/files/latest/downloadhttps://sourceforge.net/projects/phpscheduleit/files/latest/download
unzip booked-latest.zip
#---------------
# STOP WEBSERVER
#---------------
service $WEBSERVICENAME stop
#-----------------------
# CREATE DATABASE BACKUP
#-----------------------
$MYSQLDUMPPATH -u $DBUSER -p$DBPASS $DBNAME > "$WEBSERVERDIRECTORY/$BOOKEDDIRECTORY/$DBNAME.$(date +%F_%R).bak"
#-------------------------
# CREATE FILE LEVEL BACKUP
#-------------------------
mv $WEBSERVERDIRECTORY/$BOOKEDDIRECTORY/ "$WEBSERVERDIRECTORY/$BOOKEDDIRECTORY.$(date +%F_%R)/"
BACKUPDIR=$(ls -td $WEBSERVERDIRECTORY/$BOOKEDDIRECTORY*/ | head -1)
#------------------------
# MOVE NEW FILES IN PLACE
#------------------------
mv booked/ $WEBSERVERDIRECTORY/$BOOKEDDIRECTORY
#------------------
# COPY CONFIG FILES
#------------------
cd $BACKUPDIR
find . -name "*config.php" -exec cp --parents \{\} $WEBSERVERDIRECTORY/$BOOKEDDIRECTORY \;
#--------------------------
# FIX OWNER AND PERMISSIONS
#--------------------------
chown -R $WEBSERVERUSER:$WEBSERVERUSER $WEBSERVERDIRECTORY/$BOOKEDDIRECTORY
#----------------
# START WEBSERVER
#----------------
service $WEBSERVICENAME start
