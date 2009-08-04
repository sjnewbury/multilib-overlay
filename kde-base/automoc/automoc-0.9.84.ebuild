# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/automoc/automoc-0.9.84.ebuild,v 1.6 2009/04/14 23:02:29 scarabeus Exp $

EAPI="2"

inherit cmake-utils flag-o-matic multilib-native

DESCRIPTION="KDE Meta Object Compiler"
HOMEPAGE="http://www.kde.org/"
SRC_URI="mirror://kde/unstable/${PN}4/${PV}/${PN}4-${PV}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="~amd64 ~ppc ~ppc64 ~x86"
IUSE=""

DEPEND="x11-libs/qt-core:4[lib32?]"
RDEPEND="${RDEPEND}"

S="${WORKDIR}/${PN}4-${PV}"

multilib-native_src_prepare_internal() {
	if [[ ${ELIBC} = uclibc ]]; then
		append-flags -pthread
	fi
}

multilib-native_src_install_internal() {
	cmake-utils_src_install
	prep_ml_binaries /usr/bin/automoc4
}
