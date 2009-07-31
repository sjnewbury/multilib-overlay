# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-xmlpatterns/qt-xmlpatterns-4.4.2.ebuild,v 1.9 2009/02/18 20:00:56 jer Exp $

EAPI="1"
inherit qt4-build multilib-native

DESCRIPTION="The patternist module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 sparc x86 ~x86-fbsd"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[$(get_ml_usedeps)?]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/xmlpatterns tools/xmlpatterns"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}"
QCONFIG_ADD="xmlpatterns"
QCONFIG_DEFINE="QT_XMLPATTERNS"

ml-native_src_compile() {
	local myconf
	myconf="${myconf} -xmlpatterns"

	qt4-build_src_compile
}
