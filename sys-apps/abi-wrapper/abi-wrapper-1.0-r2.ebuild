# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 ppc64"
IUSE=""
DEPEND="app-portage/portage-utils"
RDEPEND=""

src_install() {
	dobin ${FILESDIR}/abi-wrapper || die "could not install abi-wrapper"
}

pkg_postinst() {
	einfo "Checking if any packages will need rebuilding..."

	local pkg files torebuild=()

	while read pkg _ files
	do
		[[ $files ]] || continue
		printf .
		torebuild+=( $( wrapper_check "$pkg" "$files" ) )
	done < <( sed -e 's/#.*//' "${PORTDIR_OVERLAY}/doc/prep_ml_binaries" )

	echo; echo

	if (( ${#torebuild[@]} )) ; then
		ewarn "You have to rebuild the following packages:"
		ewarn "${torebuild[@]/#/\\n  }"
		ewarn ""
		ewarn "For example:"
		ewarn "  emerge -av1 ${torebuild[*]/#/=}"
	else
		einfo "Nothing to rebuild"
	fi
}

wrapper_check() {
	local pkg="$1" files="$2"
	local file abi
	local pkgvers="$( qlist --exact --umap --verbose --nocolor "$pkg" | \
		awk '/\(.*lib32.*\)/ { print $1 }' )"

	for file in $files ; do

		[[ -f $file ]] || continue

		if [[ $(readlink "$file") != *abi-wrapper ]] ; then
			echo "$pkgvers"
			return
		fi

		for abi in $(get_all_abis) ; do
			if ! [[ -f $file-$abi ]] ; then
				echo "$pkgvers"
				return
			fi
		done
	done
}
