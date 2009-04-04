# Copyright 1999-2009 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/qt-webkit/qt-webkit-4.5.0.ebuild,v 1.1 2009/03/04 21:01:59 yngwin Exp $

EAPI="2"
inherit qt4-build multilib-native

DESCRIPTION="The Webkit module for the Qt toolkit"
SLOT="4"
KEYWORDS="~amd64 ~hppa ~mips ~ppc ~ppc64 -sparc ~x86"
IUSE=""

DEPEND="~x11-libs/qt-core-${PV}[debug=,ssl,lib32?]
	~x11-libs/qt-gui-${PV}[debug=,lib32?]
	|| ( ~x11-libs/qt-phonon-${PV}:${SLOT}[debug=,lib32?] media-sound/phonon[lib32?] )"
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
}

multilib-native_src_configure_internal() {
	myconf="${myconf} -webkit"
	qt4-build_src_configure
}
