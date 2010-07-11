#!/bin/bash

. "@GENTOO_PORTAGE_EPREFIX@/etc/init.d/functions.sh"

if ! type -p qfile >/dev/null; then
	einfo "Please install app-portage/portage-utils."
	exit 1
fi

einfo "Fixing broken libtool archives (.la)"
for i in $(qlist -a | grep "\.la$"); do
	sed -i \
		-e '/^dependency_libs/s:-lpng12:-lpng14:g' \
		-e '/^dependency_libs/s:libpng12.la:libpng14.la:g' \
                "${i}" 2>/dev/null
done
