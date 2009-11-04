# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-xmlpatterns/qt-xmlpatterns-4.5.3-r1.ebuild,v 1.3 2009/10/31 13:49:00 maekke Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The patternist module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~sparc x86 ~x86-fbsd"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=,lib32?]"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/xmlpatterns tools/xmlpatterns"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/QtCore
include/QtNetwork
include/QtXmlPatterns
src/network/
src/corelib/"

QCONFIG_ADD="xmlpatterns"
QCONFIG_DEFINE="QT_XMLPATTERNS"

PATCHES=(
	"${FILESDIR}/qt-4.5-nolibx11.diff"
	"${FILESDIR}/qt-${PV}-glib-event-loop.patch"
)

multilib-native_src_configure_internal() {
	myconf="${myconf} -xmlpatterns"
	qt4-build_src_configure
}
