# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.5.2-r1.ebuild,v 1.3 2009/10/09 06:04:36 maekke Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="~alpha amd64 arm ~hppa ~ia64 ~mips ppc ~ppc64 -sparc x86 ~x86-fbsd"
IUSE="kde"

DEPEND="~x11-libs/qt-core-${PV}[debug=,ssl,lib32?]
	~x11-libs/qt-gui-${PV}[debug=,lib32?]
	!kde? ( || ( ~x11-libs/qt-phonon-${PV}:${SLOT}[debug=,lib32?] media-sound/phonon[lib32?] ) )
	kde? ( media-sound/phonon[lib32?] )"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/3rdparty/webkit/WebCore tools/designer/src/plugins/qwebview"
QT4_EXTRACT_DIRECTORIES="
include/
src/
tools/"
QCONFIG_ADD="webkit"
QCONFIG_DEFINE="QT_WEBKIT"

multilib-native_src_prepare_internal() {
	[[ $(tc-arch) == "ppc64" ]] && append-flags -mminimal-toc #241900
	qt4-build_src_prepare
	# Security patch from upstream, bug 281821
	epatch "${FILESDIR}"/webkit-CVE-2009-1725.patch
}

multilib-native_src_configure_internal() {
	# This fixes relocation overflows on alpha
	use alpha && append-ldflags "-Wl,--no-relax"
	myconf="${myconf} -webkit"
	qt4-build_src_configure
}
