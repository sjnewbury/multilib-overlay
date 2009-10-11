# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit multilib

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""
DEPEND="app-portage/portage-utils"

src_install() {
	dobin ${FILESDIR}/abi-wrapper || die "could not install abi-wrapper"
}

pkg_postinst() {

	local MY_ABI="" 
	local QFILE="qfile"
	local MY_FILES=""

	for MY_ABI in $(get_all_abis); do
		if [[ ${MY_ABI} != ${DEFAULT_ABI} ]]; then
			# take the binaries listet in doc/prep_ml_binaries and append the
			# abi. Tthen ls those files. After that remove the appended abi and
			# ls the remaining ones again. Then grep out the ones already
			# pointing to the abi-wrapper and generate a list of binaries
			MY_FILES="${MY_FILES}\
			$(cat ${PORTDIR_OVERLAY}/doc/prep_ml_binaries\
			| sed "s/#.*$//"\
			| cut -d " " -f 3-\
			| tr " " "\n"\
			| tr -s "\n"\
			| sed "s@/.*@&-${MY_ABI}@"\
			| xargs -r ls 2> /dev/null\
			| sed "s@-${MY_ABI}@@"\
			| xargs -r ls -l\
			| grep -v abi-wrapper\
			| tr -s " "\
			| cut -d " " -f 9)"
		fi
	done

	MY_FILES=$(echo "${MY_FILES}" | tr -s "[:blank:]" )

	if [[ ${#MY_FILES} -gt 1 ]]; then
		ewarn you have to rebuild the following ebuilds
		echo ${MY_FILES} | tr " " "\n" | sort -u | xargs -n 1 -r ${QFILE} 
	else
		einfo nothing to rebuild
	fi
}
