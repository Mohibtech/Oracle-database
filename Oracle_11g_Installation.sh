#!/bin/bash
#
# DB Software Installation script
#Database software
#
# Prerequisites:
# - Installed package "oracle-rdbms-server-11gR2-preinstall.rpm"
# - Executed oracle-rdbms-server-11gR2-preinstall-verify
# - Copied DB software (the following archives) to $ORACLE_INSTALLFILES_LOCATION
# - linuxamd64_*_database_1of2.zip
# - linuxamd64_*_database_2of2.zip
# - linuxamd64_*_grid_1of2.zip
# - linuxamd64_*_grid_2of2.zip
# - (Optional) # passwd oracle
# - Mountpoints $ORACLE_MOUNTPOINTS exist
#
# Simon Krenger <simon@krenger.ch>

Checkpackage(){
	oracle-rdbms-server-11gR2-preinstall-verify
}

ORACLE_MOUNTPOINTS=(/u01 /u02 /u03 /u04)
ORACLE_USER=oracle
ORACLE_BASE=${ORACLE_MOUNTPOINTS[0]}/app/oracle
ORACLE_HOME=${ORACLE_BASE}/product/11.2.0/db_1
ORACLE_INVENTORY_LOCATION=/etc/oraInventory
ORACLE_INSTALLFILES_LOCATION=/home/oracle
GRID_USER=oracle
GRID_BASE=${ORACLE_MOUNTPOINTS[0]}/app/grid
GRID_HOME=${GRID_BASE}/product/11.2.0/grid_1
ORACLE_MEMORY_SIZE=2048M
unset LANG
           
### Script start
usage()
{
cat << EOF
usage: $0 [-h] [-u ORACLE_USER] [-m ORACLE_MEMORY_SIZE] [-i INSTALLFILES_DIR]

This script is used to install Oracle Grid Infrastructure and the Oracle
database software. The default settings will install the database software
according to the OFA standard.

OPTIONS:
-h Show this message
-i Folder that contains the installation ZIP files. Defaults to "$ORACLE_INSTALLFILES_LOCATION"
-u User that owns the Oracle software installation. Defaults to "$ORACLE_USER"
-m Aggregate shared memory size for all databases on this machine.
Defaults to $ORACLE_MEMORY_SIZE.
EOF
}

# Parse arguments
check_parse_arguments(){
	while getopts "hi:u:m:" OPTION
	do
		case $OPTION in
			h)
				usage
				exit 1
				;;
			i)
				ORACLE_INSTALLFILES_LOCATION=$OPTARG
				;;
			u)
				ORACLE_USER=$OPTARG
				;;
			m)
				ORACLE_MEMORY_SIZE=$OPTARG
				;;
			?)
				usage
				exit
				;;
		esac
	done
}

# Check if run as root
Check_root_oracle_user() {
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 1>&2
		exit 1
	fi
	
	id $ORACLE_USER 2>/dev/null
	if [ $? -eq 0 ]; then
		echo "User $ORACLE_USER found, proceeding..."
	else
		echo "User $ORACLE_USER not found, aborting..."
		exit 1
	fi 
}


# Check necessary programs installed
Check_programs_are_installed() {
chk_unzip(){
	which unzip
	if [ $? -eq 0 ]; then
		echo "unzip is installed"
	else
		echo "unzip not found, aborting..."
		exit 1
	fi
}

chk_preinstall(){
	which oracle-rdbms-server-11gR2-preinstall-verify
		if [ $? -eq 0 ]; then
			echo "oracle-rdbms-server-11gR2-preinstall-verify is installed"
		else
			echo "oracle-rdbms-server-11gR2-preinstall-verify not found, aborting..."
		exit 1
	fi
}

chk_ntpd(){
	which ntpd
	if [ $? -eq 0 ]; then
		echo "ntpd is installed"
	else
		echo "ntpd not found, aborting..."
		exit 1
	fi
}

chk_ntpdate(){
	which ntpdate
	if [ $? -eq 0 ]; then
		echo "ntpdate is installed"
	else
		echo "ntpdate not found, aborting..."
		exit 1
	fi
}

chk_unzip
chk_preinstall
#chk_ntpd
#chk_ntpdate

}


Check_Zip_files () {
	if [ -d "$ORACLE_INSTALLFILES_LOCATION" ]; then
		echo "$ORACLE_INSTALLFILES_LOCATION exists"
		if [ `ls -l $ORACLE_INSTALLFILES_LOCATION/p13390677_112040*.zip | wc -l` -eq 2 ]; then
			echo "Correct amount of ZIPs found, proceeding..."
		else
			echo "No or wrong installation ZIP files found."
			echo "Please make sure p13390677_112040_Linux-x86-64_1of7.zip,p13390677_112040_Linux-x86-64_2of7.zip are located in $ORACLE_INSTALLFILES_LOCATION"
			exit 1
		fi
	else
		echo "$ORACLE_INSTALLFILES_LOCATION does not exist, aborting..."
		exit 1
	fi
}

# Prepare filesystem

# Make sure the mountpoints exist
# This command will create them as folders if necessary
Check_mount_points_exists () {
	for mountpoint in ${ORACLE_MOUNTPOINTS[*]}
	do
		mkdir -p $mountpoint
		chown -R ${ORACLE_USER}:oinstall $mountpoint
	done

	mkdir -p ${ORACLE_HOME}
	mkdir -p ${ORACLE_INVENTORY_LOCATION}
	chown -R ${ORACLE_USER}:oinstall ${ORACLE_BASE}
	chown -R ${ORACLE_USER}:oinstall ${ORACLE_INVENTORY_LOCATION}
}

# Prepare groups and users
Check_adding_groups() {
	groupadd asmadmin
	groupadd asmoper
	groupadd dgdba
	groupadd bckpdba
	groupadd kmdba
	usermod -a -G dba,asmoper,asmadmin,dgdba,bckpdba,kmdba ${ORACLE_USER}
}

# Modify Files
modifying_Files() {
	# Modify /etc/sysconfig/ntpd
	modify_NTPD (){
		service ntpd stop
		echo 'OPTIONS="-u ntp:ntp -x -p /var/run/ntpd.pid"' > /etc/sysconfig/ntpd
		ntpdate pool.ntp.org
		service ntpd start 
    }

    # Modify /etc/hosts
    modify_hosts () {
		cp /etc/hosts /etc/hosts.original
		echo "127.0.0.1 `hostname -s` `hostname`" >> /etc/hosts
    }

    # Modify /etc/fstab
    modify_fstab() {
		mv /etc/fstab /etc/fstab.original
		cat /etc/fstab.original | awk '$3~"^tmpfs$"{$4="size='$ORACLE_MEMORY_SIZE'"}1' OFS="\t" > /etc/fstab
		mount -t tmpfs shmfs -o size=$ORACLE_MEMORY_SIZE /dev/shm
    }
	
#modify_NTPD
modify_hosts
modify_fstab
	
}

# Register OraInventory
Check_Regiser_oraInventory () {
	${ORACLE_INVENTORY_LOCATION}/orainstRoot.sh
}

# Installation of Database Software
# Oracle database software
DB_Software_install () {

cd ${ORACLE_INSTALLFILES_LOCATION}
unzip ${ORACLE_INSTALLFILES_LOCATION}/p13390677_112040_Linux-x86-64_1of7.zip
unzip ${ORACLE_INSTALLFILES_LOCATION}/p13390677_112040_Linux-x86-64_2of7.zip
chown -R ${ORACLE_USER}:oinstall ${ORACLE_INSTALLFILES_LOCATION}/database

#TODO: Check if everything worked as expected and only remove if no errors occured
cd ${ORACLE_INSTALLFILES_LOCATION}/database

echo "oracle.install.responseFileVersion=/oracle/install/rspfmt_dbinstall_response_schema_v12.1.0
oracle.install.option=INSTALL_DB_SWONLY
ORACLE_HOSTNAME=hostname
UNIX_GROUP_NAME=oinstall
INVENTORY_LOCATION=${ORACLE_INVENTORY_LOCATION}
SELECTED_LANGUAGES=en
ORACLE_HOME=${ORACLE_HOME}
ORACLE_BASE=${ORACLE_BASE}
oracle.install.db.InstallEdition=EE
oracle.install.db.DBA_GROUP=dba
oracle.install.db.BACKUPDBA_GROUP=bckpdba
oracle.install.db.DGDBA_GROUP=dgdba
oracle.install.db.KMDBA_GROUP=kmdba
SECURITY_UPDATES_VIA_MYORACLESUPPORT=false
DECLINE_SECURITY_UPDATES=true
oracle.installer.autoupdates.option=SKIP_UPDATES" > ${ORACLE_INSTALLFILES_LOCATION}/db_install.rsp


echo "Now installing Database software. This may take a while..."
su ${ORACLE_USER} -c "cd ${ORACLE_INSTALLFILES_LOCATION}/database; ./runInstaller -silent -waitForCompletion -responseFile ${ORACLE_INSTALLFILES_LOCATION}/db_install.rsp"
}

Execute_root_script () {
	# Configure DB software
	${ORACLE_HOME}/root.sh

	# Update .bash_profile of oracle user
	su ${ORACLE_USER} -c "echo '
	#Oracle config
	export ORACLE_HOME=${ORACLE_HOME}
	export PATH=$PATH:\$ORACLE_HOME/bin' >> ~/.bash_profile"
}


# Create an Oracle listener in the Oracle_HOME
Check_add_Listener () {
						echo "Adding listener..."


						echo "[GENERAL]
						RESPONSEFILE_VERSION=\"11.2\"
						CREATE_TYPE=\"CUSTOM\"
						SHOW_GUI=false
						[oracle.net.ca]
						INSTALLED_COMPONENTS={\"server\",\"net8\",\"javavm\"}
						INSTALL_TYPE=\"\"typical\"\"
						LISTENER_NUMBER=1
						LISTENER_NAMES={\"LISTENER\"}
						LISTENER_PROTOCOLS={\"TCP;1521\"}
						LISTENER_START=\"\"LISTENER\"\"
						NAMING_METHODS={\"TNSNAMES\",\"ONAMES\",\"HOSTNAME\"}
						NSN_NUMBER=1
						NSN_NAMES={\"EXTPROC_CONNECTION_DATA\"}
						NSN_SERVICE={\"PLSExtProc\"}
						NSN_PROTOCOLS={\"TCP;HOSTNAME;1521\"}" > ${ORACLE_INSTALLFILES_LOCATION}/netca.rsp


						su ${ORACLE_USER} -c "${ORACLE_HOME}/bin/netca -silent -responseFile ${ORACLE_INSTALLFILES_LOCATION}/netca.rsp"
						echo "Listener configured, now adding to CRS..."
						su ${ORACLE_USER} -c "${ORACLE_HOME}/bin/srvctl add listener -endpoints TCP:1521 -oraclehome ${GRID_HOME}"
						su ${ORACLE_USER} -c "${ORACLE_HOME}/bin/srvctl start listener"

                     }



Checkpackage
check_parse_arguments
Check_if_user_is_root
Check_Zip_files
Check_programs_are_installed 
Check_mount_points_exists
Check_adding_groups
modifying_Files
Check_Regiser_oraInventory
DB_Software_install
Execute_root_script
Check_add_Listener
echo "Installation finished. Check the logfiles for errors"
