# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-xmlpatterns/qt-xmlpatterns-4.6.2.ebuild,v 1.7 2010/08/04 14:59:08 maekke Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The patternist module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~mips ppc ppc64 ~sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[aqua=,debug=,exceptions,lib32?]"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/xmlpatterns tools/xmlpatterns"
QT4_EXTRACT_DIRECTORIES="${QT4_TARGET_DIRECTORIES}
include/QtCore
include/QtXml
include/QtNetwork
include/QtXmlPatterns
src/network/
src/xml/
src/corelib/"

QCONFIG_ADD="xmlpatterns"
QCONFIG_DEFINE="QT_XMLPATTERNS"

PATCHES=(
	"${FILESDIR}/qt-4.6-nolibx11.patch"
)

multilib-native_src_configure_internal() {
	myconf="${myconf} -xmlpatterns"
	qt4-build_src_configure
}
