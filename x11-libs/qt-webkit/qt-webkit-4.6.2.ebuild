# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.6.2.ebuild,v 1.9 2010/09/13 21:23:54 klausman Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="alpha amd64 arm ~hppa ~ia64 ~mips ppc ppc64 -sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="kde dbus"

DEPEND="~x11-libs/qt-core-${PV}[aqua=,debug=,ssl,lib32?]
	~x11-libs/qt-dbus-${PV}[aqua=,debug=,lib32?]
	~x11-libs/qt-gui-${PV}[aqua=,dbus,debug=,lib32?]
	~x11-libs/qt-xmlpatterns-${PV}[aqua=,debug=,lib32?]
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}:${SLOT}[aqua=,dbus,debug=,lib32?]
		media-sound/phonon[aqua=,lib32?] ) )
	kde? ( || ( media-sound/phonon[aqua=,lib32?] ~x11-libs/qt-phonon-${PV}:${SLOT}[aqua=,dbus=,debug,lib32?] ) )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/3rdparty/webkit/WebCore tools/designer/src/plugins/qwebview"
QT4_EXTRACT_DIRECTORIES="
include/
src/
tools/"
QCONFIG_ADD="webkit"
QCONFIG_DEFINE="QT_WEBKIT"

PATCHES=(
	"${FILESDIR}"/${PN}-4.6.0-solaris-strnstr.patch
)

multilib-native_src_prepare_internal() {
	[[ $(tc-arch) == "ppc64" ]] && append-flags -mminimal-toc #241900
	qt4-build_src_prepare
}

multilib-native_src_configure_internal() {
	myconf="${myconf} -webkit"
	qt4-build_src_configure
}
