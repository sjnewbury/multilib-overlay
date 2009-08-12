#!/bin/sh

for i in /usr/portage/local/multilib-overlay/eclass/*.eclass; do
	ECLASS_NAME="`basename $i`"

	if [ "$ECLASS_NAME" = "multilib-native.eclass" ]; then
		continue
	fi

	OVERLAY_VERSION="`grep Header $i | cut -d ',' -f 2 | cut -d ' ' -f 2`"
	PORTAGE_VERSION="`grep Header /usr/portage/eclass/$ECLASS_NAME | cut -d ',' -f 2 | cut -d ' ' -f 2`"

	if [ ! "$OVERLAY_VERSION" = "$PORTAGE_VERSION" ]; then
		echo "$ECLASS_NAME:"
		echo "overlay: $OVERLAY_VERSION"
		echo "portage: $PORTAGE_VERSION"
		echo
	fi
done
