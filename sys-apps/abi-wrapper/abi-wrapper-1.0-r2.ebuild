# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit eutils multilib

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS=""
IUSE=""

src_install() {
	dobin ${FILESDIR}/abi-wrapper || die "could not install abi-wrapper"
}

pkg_postinst() {
	einfo "Checking if any packages will need rebuilding..."

	local pkg files pkgver file badpkgs torebuild abi

	while read pkg _ files
	do
		[[ $files ]] || continue

		while read -r pkgver ; do
			printf .

			if built_with_use --missing false "=$pkgver" "lib32" ; then
				for file in $files ; do

					[[ -f $file ]] || continue

					if [[ $(readlink "$file") != *abi-wrapper ]] ; then
						badpkgs+="  =$pkgver\n"
						continue
					fi

					for abi in $(get_all_abis) ; do
						if ! [[ -f $file-$abi ]] ; then
							badpkgs+="  =$pkgver\n"
							continue
						fi
					done
				done
			fi
		done < <( portageq match "${ROOT:-/}" "$pkg" )
	done < <( sed -e 's/#.*//' "${PORTDIR_OVERLAY}/doc/prep_ml_binaries" )

	echo; echo

	if [[ $badpkgs ]] ; then
		ewarn "You have to rebuild the following packages:\n\n${badpkgs}"
	else
		einfo "Nothing to rebuild"
	fi
}
