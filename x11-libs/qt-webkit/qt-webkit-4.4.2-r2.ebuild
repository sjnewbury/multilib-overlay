# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.4.2-r2.ebuild,v 1.4 2009/08/25 18:15:02 klausman Exp $

EAPI="2"
inherit qt4-build flag-o-matic toolchain-funcs multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit."
HOMEPAGE="http://www.trolltech.com/"

LICENSE="|| ( GPL-3 GPL-2 )"
SLOT="4"
KEYWORDS="alpha ~amd64 ~hppa ~ia64 ~mips ppc ~ppc64 -sparc x86"
IUSE=""

DEPEND="~x11-libs/qt-gui-${PV}[lib32?]
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

multilib-native_src_prepare_internal() {
	# Apply bugfix patches from qt-copy (KDE)
	epatch "${FILESDIR}"/0249-webkit-stale-frame-pointer.diff
	# Security patch from upstream, bug 281821
	epatch "${FILESDIR}"/webkit-CVE-2009-1725.patch
	qt4-build_src_prepare
}

multilib-native_src_configure_internal() {
	local myconf
	myconf="${myconf} -webkit"
	qt4-build_src_configure
}
