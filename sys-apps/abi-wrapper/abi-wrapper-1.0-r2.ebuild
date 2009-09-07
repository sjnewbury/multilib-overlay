# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""
DEPEND="app-portage/portage-utils"
RDEPEND=""

src_install() {
	dobin ${FILESDIR}/abi-wrapper || die "could not install abi-wrapper"
}

pkg_postinst() {
	einfo "Checking if any packages will need rebuilding..."
	
	local pkg file files badfiles torebuild abi

	while read pkg _ files
	do
		[[ $pkg = \#* ]] && continue
		for file in $files ; do
			[[ -f $file ]] || continue

			if [[ $(readlink "$file") != *abi-wrapper ]] ; then
				badfiles+=" $file"
				continue
			fi

			for abi in $(get_all_abis) ; do
				if ! [[ -f $file-$abi ]] ; then
					badfiles+=" $file"
					continue
				fi
			done
		done
	done <"${PORTDIR_OVERLAY}/doc/prep_ml_binaries"

	[[ $badfiles ]] && torebuild="$(qfile -e -q $badfiles | sort -u)"
	if [[ $torebuild ]] ; then
		ewarn "You have to rebuild the following ebuilds:\n${torebuild}"
	else
		einfo "Nothing to rebuild"
	fi
}
