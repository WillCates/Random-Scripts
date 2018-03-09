#!/bin/bash
#
###################
#
#	Will Cates
#	temproot.sh v1.1
#	20160711
#	Description: Gives temporary root access via the /etc/sudoers.d/temproot file. 
# Use: This is for system admins to use to temporarily grant another user root access. You have to have root yourself to use this.
#
###################
#
#	Update v1.1: Added support for checking to make sure that the user is present on the system, before actually adding the temproot line.
#	Will Cates, 20160712
#
###################


#
##
###
#### - - - ANSWER ME FOOL! - - - - - +
###
##
#

answer_me()
{
echo
echo "Do you wish to continue? [yes|no]: "
read CONTINUE
CONTINUE=$(echo $CONTINUE | awk '{print tolower($0)}')

case $CONTINUE in
	"yes")  main ;;
	"no") usage ;;
	*)      echo "Please answer yes or no" ; answer_me ;;
esac
}

#
##
###
#### - - - - - MAIN - - - - - - - +
###
##
#

main()
{
ROOT_PRIV="$USER_ACTIVE ALL=\($USER_GIVE\)      NOPASSWD: ALL"
for SERVER in `cat $SERVERS_LIST`
do
	PASS=1
	USER_EXISTS=`ssh $SERVER "cat /etc/passwd |grep -Ec \"^$USER_ACTIVE:\""`
	if [ $USER_EXISTS -ge 1 ]
	then
		echo "ACTIVE DAYS: ${DAYS_ACTIVE}"
		ssh -tt $SERVER "umask 0337 && sudo touch /etc/sudoers.d/temproot; /bin/echo ${ROOT_PRIV} |sudo /usr/bin/tee -a /etc/sudoers.d/temproot; echo \"sed -i \\\"/${USER_ACTIVE}.*ALL$/d\\\" /etc/sudoers.d/temproot\" | sudo at now + \"${DAYS_ACTIVE}\" day"
	else
		echo
		echo "USER $USER_ACTIVE NOT FOUND ON $SERVER"
		echo
	fi
done
}

#
##
###
#### - - - - - USAGE - - - - - - +
###
##
#

usage()
{
echo
echo "./temproot.sh -u [USER_TO_SUDO] -s [LIST_OF_SERVERS] -r [DAYS_TO_RETAIN_ACCESS] {-h|-d|-g} [HELP|DEBUG|GO]"
echo
exit 0
}

#
##
###
#### - - - - - DEBUG - - - - - - +
###
##
#

debug()
{
CONFIGURATION="$USER_ACTIVE ALL=($USER_GIVE)      NOPASSWD: ALL"
echo
echo "You will be adding this line:"
echo
echo "$CONFIGURATION"
echo
echo "To this file: /etc/sudoers.d/temproot"
echo
echo "On these servers:"
echo
for SERVER in `cat $SERVERS_LIST`
do
	echo $SERVER
done
echo
echo "For a total of $DAYS_ACTIVE days."
echo
}

#
##
###
#### - - - - - SETUP - - - - - - +
###
##
#
while getopts 's:r:u:hdgU:' opt
do
        case "${opt}" in
                s) SERVERS_LIST="$OPTARG" ;;
                r) DAYS_ACTIVE="$OPTARG" ;;
		u) USER_ACTIVE="$OPTARG" ;;
		U) USER_GIVE="$OPTARG" ;;
        	h) HELP_SW=1 ;;
		d) DEBUG_SW=1 ;;
		g) GO_SW=1 ;;
	esac
done

if [ ! -f "${SERVERS_LIST}" ]
then
	echo
	echo "Please provide a valid server list"
	usage
fi

if [ -z "${USER_GIVE}" ]
then
        USER_GIVE="root"
fi

if [ -z "${DAYS_ACTIVE}" ] || [ "${DAYS_ACTIVE}" -gt 90 ] || [ "${DAYS_ACTIVE}" -lt 1 ]
then
        echo
        echo "You must enter a number of days less than or equal to '90' for the account's root access to be removed. And NO NEGATIVE NUMBERS OR 0"
        usage
fi

if [ -z "${USER_ACTIVE}" ]
then
	echo
	echo "Please enter a valid user"
	usage
fi

if ([ -n "${HELP_SW}" ] && [ -n "${DEBUG_SW}" ]) || ([ -n "${HELP_SW}" ] && [ -n "${GO_SW}" ]) || ([ -n "${DEBUG_SW}" ] && [ -n "${GO_SW}" ])
then
	echo
	echo "You can only enter one of these flags: [-h|-d|-g]"
fi

if [ -n "${HELP_SW}" ]
then
	usage
elif [ -n "${DEBUG_SW}" ]
then
	debug
elif [ -n "${GO_SW}" ]
then
	debug
	answer_me
else
	echo
	echo "Please pick one flag of [-h|-d|-g] (Help, Debug, Go)"
	usage
fi
