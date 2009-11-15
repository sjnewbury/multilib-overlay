# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="2"

DESCRIPTION="Wraps binarys that behave abi dependand"
HOMEPAGE="www.gentoo.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64"
IUSE=""

src_prepare() {
	cp "${FILESDIR}"/abi-wrapper "${T}"/abi-wrapper
	echo cp "${FILESDIR}"/abi-wrapper "${T}"/abi-wrapper
	local abis="${DEFAULT_ABI} ${MULTILIB_ABIS/${DEFAULT_ABI}}"
	sed -i "s/PLACEHOLDER_FOR_HARDCODED_ABIS/${abis}/" "${T}"/abi-wrapper
}

src_install() {
	dobin "${T}"/abi-wrapper || die
}
