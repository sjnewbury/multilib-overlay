# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.5.3-r3.ebuild,v 1.6 2010/08/11 21:35:12 josejx Exp $

EAPI="2"
inherit eutils qt4-build flag-o-matic multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha amd64 ~arm hppa ~ia64 ~mips ppc ppc64 ~sparc x86 ~x86-fbsd"
IUSE="dbus kde"

DEPEND="~x11-libs/qt-core-${PV}[debug=,ssl,lib32?]
	~x11-libs/qt-gui-${PV}[dbus?,debug=,lib32?]
	dbus? ( ~x11-libs/qt-dbus-${PV}[debug=,lib32?] )
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}:${SLOT}[dbus=,debug=,lib32?]
		media-sound/phonon[lib32?] ) )
	kde? ( media-sound/phonon[lib32?] )"
RDEPEND="${DEPEND}"

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
	epatch "${FILESDIR}"/30_webkit_unaligned_access.diff #235685
	epatch "${FILESDIR}"/${P}-no-javascript-crash.patch #295573

	# patches graciously borrowed from Fedora for bug #314193
	epatch "${FILESDIR}"/${P}-cve-2010-0046-css-format-mem-corruption.patch
	epatch "${FILESDIR}"/${P}-cve-2010-0049-freed-line-boxes-ltr-rtl.patch
	epatch "${FILESDIR}"/${P}-cve-2010-0050-crash-misnested-style-tags.patch
	epatch "${FILESDIR}"/${P}-cve-2010-0052-destroyed-input-cached.patch

	qt4-build_src_prepare
}

multilib-native_src_configure_internal() {
	# This fixes relocation overflows on alpha
	use alpha && append-ldflags "-Wl,--no-relax"
	myconf="${myconf} -webkit $(qt_use dbus qdbus)"
	qt4-build_src_configure
}
