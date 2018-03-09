#!/bin/bash
#
#	Will Cates
#	20160331
#	wdiff.sh - takes a known good list [FILE], compares to an older version of the list, tells you what needs to be added/removed. 
#

OLD="/tmp/missing_wdiff"
NEW="/tmp/new_wdiff"
echo "" >$OLD
echo "" >$NEW

usage()
{
echo
echo "For best results, provide only a single column in the list, of letters only - no periods, domains, or special chars"
echo
echo "./wdiff.sh -g [KNOWN_GOOD_LIST_FILE] -o {OLD_LIST_FILE]"
unset KNOWN_GOOD
unset OLD_LIST
exit 1
}

main()
{
for ITEM in `cat $KNOWN_GOOD |sort -n |uniq`
do
	COUNT=$(cat $OLD_LIST |grep -ic $ITEM)
	if [ $COUNT -eq 0 ]
	then
		echo $ITEM >>$NEW
	elif [ $COUNT -eq 1 ]
	then
		echo "$ITEM Present in Old List"
	else
		echo "UNKNOWN ERROR"
	fi
done

for ITEM in `cat $OLD_LIST |sort -n |uniq`
do
	COUNT=$(cat $KNOWN_GOOD |grep -ic $ITEM)
	if [ $COUNT -eq 0 ]
        then
                echo $ITEM >>$OLD
        elif [ $COUNT -eq 1 ]
        then
                echo "$ITEM present in known good list"
        else
                echo "UNKNOWN ERROR"
        fi
done
unset KNOWN_GOOD
unset OLD_LIST
sleep 2
echo
echo "+------------------------------------------------+"
echo
sleep 1
echo
echo "THESE ITEMS NEED TO BE ADDED:"
sleep 1
echo
cat $NEW
echo
echo
sleep 1
echo "THESE ITEMS NEED TO BE REMOVED:"
sleep 1
echo
cat $OLD
echo
echo
}

while getopts 'g:o:' opt
do
	case "${opt}" in
		g) KNOWN_GOOD="$OPTARG" ;;
		o) OLD_LIST="$OPTARG" ;;
	esac
done

if [ ! -f $KNOWN_GOOD ] || [ ! -f $OLD_LIST ]
then
	usage
elif [ -f $KNOWN_GOOD ] && [ -f $OLD_LIST ] && [ $KNOWN_GOOD == $OLD_LIST ]
then
	echo $KNOWN_GOOD
	echo $OLD_LIST
	echo "You provided the same file for both arguments!"
	echo
	usage
else
	main
fi
