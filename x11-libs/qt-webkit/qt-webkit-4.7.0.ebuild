# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.7.0.ebuild,v 1.1 2010/09/21 15:07:37 tampakrap Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 -sparc ~x86 ~x86-fbsd ~x86-freebsd ~amd64-linux ~x86-linux ~ppc-macos ~x86-macos ~x64-solaris ~x86-solaris"
IUSE="dbus kde"

DEPEND="~x11-libs/qt-core-${PV}[debug=,ssl,lib32?]
	~x11-libs/qt-gui-${PV}[dbus?,debug=,lib32?]
	~x11-libs/qt-multimedia-${PV}[debug=,lib32?]
	~x11-libs/qt-xmlpatterns-${PV}[debug=,lib32?]
	dbus? ( ~x11-libs/qt-dbus-${PV}[debug=,lib32?] )
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}:${SLOT}[dbus=,debug=,lib32?]
		media-sound/phonon[lib32?] ) )
	kde? ( media-sound/phonon[lib32?] )"
RDEPEND="${DEPEND}"

multilib-native_pkg_setup_internal() {
	QT4_TARGET_DIRECTORIES="
		src/3rdparty/webkit/JavaScriptCore
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
