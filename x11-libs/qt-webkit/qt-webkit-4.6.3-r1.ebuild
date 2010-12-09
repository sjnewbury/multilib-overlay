# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.6.3-r1.ebuild,v 1.8 2010/11/14 16:49:34 armin76 Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="alpha amd64 arm ia64 ~mips ppc ~ppc64 -sparc x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="dbus kde"

DEPEND="~x11-libs/qt-core-${PV}[aqua=,debug=,ssl,lib32?]
	~x11-libs/qt-gui-${PV}[aqua=,dbus?,debug=,lib32?]
	~x11-libs/qt-xmlpatterns-${PV}[aqua=,debug=,lib32?]
	dbus? ( ~x11-libs/qt-dbus-${PV}[aqua=,debug=,lib32?] )
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}:${SLOT}[aqua=,dbus=,debug=,lib32?]
		media-sound/phonon[aqua=,lib32?] ) )
	kde? ( || ( media-sound/phonon[aqua=,lib32?] ~x11-libs/qt-phonon-${PV}:${SLOT}[aqua=,dbus=,debug,lib32?] ) )"
RDEPEND="${DEPEND}"

PATCHES=(
	"${FILESDIR}"/${PN}-4.6.0-solaris-strnstr.patch
	"${FILESDIR}"/${P}-flash-plugin-segfault.patch
)

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="
		src/3rdparty/webkit/WebCore
		tools/designer/src/plugins/qwebview"
	QT4_EXTRACT_DIRECTORIES="
		include/
		src/
		tools/"
	QCONFIG_ADD="webkit"
	QCONFIG_DEFINE="QT_WEBKIT"

	qt4-build_pkg_setup
}

multilib-native_src_prepare_internal() {
	[[ $(tc-arch) == "ppc64" ]] && append-flags -mminimal-toc #241900
	qt4-build_src_prepare
}

multilib-native_src_configure_internal() {
	myconf="${myconf} -webkit $(qt_use dbus qdbus)"
	qt4-build_src_configure
}
