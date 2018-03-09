#!/bin/bash
#
#	Will Cates
#	burst.sh
#	Description: Burst file into multiple files of specified number of lines, with the last file containing the remainder of lines.
#	20160502
#
main()
{
LINEST=`cat $FILE |wc -l`
DIVIDES=$(expr $LINEST / $LINES)
EXTENSION=`echo $FILE |grep -Eo "\.[a-zA-Z]{1,3}$"`
BASENAME=`basename $FILE $EXTENSION`
x=2

cat $FILE |head -$LINES >${BASENAME}-01${EXTENSION}
while [ $x -le $DIVIDES ]
do
	RANGE=$((x*LINES))
	if [ $x -le 9 ]
	then
		cat $FILE |head -$RANGE |tail -$LINES >${BASENAME}-0${x}${EXTENSION}
	else
		cat $FILE |head -$RANGE |tail -$LINES >${BASENAME}-${x}${EXTENSION}
	fi
	x=$(( $x + 1 ))
done

REMAINDER=$((LINEST - (DIVIDES*LINES)))
if [ $DIVIDES -le 8 ]
then
	cat $FILE |tail -${REMAINDER} >${BASENAME}-0$((DIVIDES + 1))${EXTENSION}
else
	cat $FILE |tail -${REMAINDER} >${BASENAME}-$((DIVIDES + 1))${EXTENSION}
fi
}

usage()
{
echo "./burst.sh -l LINES -f FILE"
}


while getopts 'l:f:' opt
do
        case "${opt}" in
                l) LINES="$OPTARG" ;;
                f) FILE="$OPTARG" ;;
        esac
done

if [ -z $LINES ] || [ ! -f $FILE ]
then
        usage
else
        main
fi
