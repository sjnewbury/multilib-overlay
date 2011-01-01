# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_unpack() {
	local abis="${DEFAULT_ABI} ${MULTILIB_ABIS/${DEFAULT_ABI}}"
	sed "s/@HARDCODED_ABIS@/${abis}/" "${FILESDIR}"/abi-wrapper > "${WORKDIR}"/abi-wrapper
}
src_install() {
	dobin abi-wrapper || die
}
