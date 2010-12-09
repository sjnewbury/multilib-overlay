# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libXft/libXft-2.2.0.ebuild,v 1.3 2010/12/04 12:36:53 scarabeus Exp $

EAPI=3
inherit xorg-2 flag-o-matic multilib-native

DESCRIPTION="X.Org Xft library"

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~x86-fbsd ~x86-freebsd ~x86-interix ~amd64-linux ~x86-linux ~ppc-macos ~x64-macos ~x86-macos ~sparc-solaris ~sparc64-solaris ~x64-solaris ~x86-solaris ~x86-winnt"
IUSE=""

RDEPEND=">=x11-libs/libXrender-0.8.2[lib32?]
	x11-libs/libX11[lib32?]
	x11-libs/libXext[lib32?]
	media-libs/freetype[lib32?]
	media-libs/fontconfig[lib32?]
	x11-proto/xproto
	virtual/ttf-fonts"
DEPEND="${RDEPEND}"

multilib-native_src_install_internal() {
	multilib-native_check_inherited_funcs src_install
	prep_ml_binaries /usr/bin/xft-config
}
