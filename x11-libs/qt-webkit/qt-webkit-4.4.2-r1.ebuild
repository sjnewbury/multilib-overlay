# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.4.2-r1.ebuild,v 1.6 2009/04/28 15:35:39 jer Exp $

EAPI="2"
inherit qt4-build flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha amd64 hppa ia64 ~mips ppc ppc64 -sparc x86"
IUSE=""

DEPEND="~x11-libs/qt-gui-${PV}[$(get_ml_usedeps)]
	!<=x11-libs/qt-4.4.0_alpha:${SLOT}"
RDEPEND="${DEPEND}"

QT4_TARGET_DIRECTORIES="src/3rdparty/webkit/WebCore tools/designer/src/plugins/qwebview"
QT4_EXTRACT_DIRECTORIES="src/3rdparty/webkit src/3rdparty/sqlite
tools/designer/src/plugins/qwebview"
QCONFIG_ADD="webkit"
QCONFIG_DEFINE="QT_WEBKIT"

# see bug 236781
QT4_BUILT_WITH_USE_CHECK="${QT4_BUILT_WITH_USE_CHECK}
	~x11-libs/qt-core-${PV} ssl"

src_unpack() {
	[[ $(tc-arch) == "ppc64" ]] && append-flags -mminimal-toc #241900

	qt4-build_src_unpack
}

ml-native_src_prepare() {
	# Apply bugfix patches from qt-copy (KDE)
	epatch "${FILESDIR}"/0249-webkit-stale-frame-pointer.diff
	qt4-build_src_prepare
}

ml-native_src_configure() {
	local myconf
	myconf="${myconf} -webkit"
	qt4-build_src_configure
}
