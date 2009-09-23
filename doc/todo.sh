#!/bin/bash

echo "the tool is broken, forget it." 1>&2 && exit 1

LIST=$(find . -name "*.done")
SUM=0
DONE_SUM=0

for DONE_FILE in $LIST; do
	PACKAGE_FILE=$(basename $DONE_FILE .done)
	COUNT=$(cat $PACKAGE_FILE | wc -l)
	SUM=$(expr $SUM + $COUNT)
	TODO_LIST=$(diff -u $PACKAGE_FILE $DONE_FILE | grep "^-[[:alpha:]]")
	DONE_COUNT=$(echo "$TODO_LIST" | wc -l)
	DONE_SUM=$(expr $DONE_SUM + $DONE_COUNT)
	echo " $PACKAGE_FILE - $DONE_COUNT of $COUNT package(s) to do!"
	echo "$TODO_LIST"
	echo
done

echo $DONE_SUM of $SUM packages to do!
