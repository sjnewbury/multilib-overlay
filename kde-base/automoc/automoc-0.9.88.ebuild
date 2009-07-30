# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/kde-base/automoc/automoc-0.9.88.ebuild,v 1.13 2009/06/18 10:50:02 aballier Exp $

EAPI="2"

MY_PN="automoc4"
MY_P="$MY_PN-${PV}"

inherit cmake-utils flag-o-matic multilib-native

DESCRIPTION="KDE Meta Object Compiler"
HOMEPAGE="http://www.kde.org"
SRC_URI="mirror://kde/stable/${MY_PN}/${PV}/${MY_P}.tar.bz2"

LICENSE="as-is"
SLOT="0"
KEYWORDS="alpha amd64 hppa ia64 ppc ppc64 x86 ~x86-fbsd"
IUSE=""

DEPEND="x11-libs/qt-core:4[lib32?]"
RDEPEND="${RDEPEND}"

S="${WORKDIR}/${MY_P}"

multilib-native_src_prepare_internal() {
	if [[ ${ELIBC} = uclibc ]]; then
		append-flags -pthread
	fi
}

multilib-native_src_install_internal() {
	cmake-utils_src_install
	prep_ml_binaries /usr/bin/automoc4
}
